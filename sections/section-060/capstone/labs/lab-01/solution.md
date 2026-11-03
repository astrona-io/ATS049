# Solution

This capstone combines quantiles, aggregation across instances, the restart of `bridge-1:8080`, the mean and the share under a threshold.

The steps below test each expression with the query helper, then store it. Values that come from `rate` or a division are approximate here; compare them with your own output.

## Task 1

Take the rate of the buckets, aggregate by `instance` and `le`, and pass the result to `histogram_quantile`.

Test it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'histogram_quantile(0.9, sum by (instance, le) (rate(http_request_duration_seconds_bucket[5m])))'
```

You should see two lines with the label `instance`: about 0.375 and about 0.4167.

## Task 2

A comparison operator between a vector and a number keeps only the series for which the comparison is true and keeps their values.

Test it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'histogram_quantile(0.9, sum by (instance, le) (rate(http_request_duration_seconds_bucket[5m]))) > 0.4'
```

You should see one line for `bridge-1:8080` with a value of about 0.4167, and no line for `bridge-0:8080`.

## Task 3

Add the rates of all instances in the numerator and the denominator, then divide once.

Test it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum(rate(http_request_duration_seconds_sum[5m])) / sum(rate(http_request_duration_seconds_count[5m]))'
```

You should see one line without labels, with a value of about 0.2333.

## Task 4

Divide the summed rate of the bucket `le="0.25"` by the summed rate of the count.

Test it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum(rate(http_request_duration_seconds_bucket{le="0.25"}[5m])) / sum(rate(http_request_duration_seconds_count[5m]))'
```

You should see one line without labels, with a value of about 0.8333.

## Task 5

`rate` treats a drop of a counter as a reset, so the buckets stay usable. Add the bucket rates of both instances and take the quantile once, with the window `[5m]`.

Test it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'histogram_quantile(0.9, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))' --time 1767227475
```

You should see one line without labels, with a value of about 0.392.

## Store the answers

Write all expressions in one command:

```sh
kubectl -n starfleet create configmap answers \
  --from-literal=q1='histogram_quantile(0.9, sum by (instance, le) (rate(http_request_duration_seconds_bucket[5m])))' \
  --from-literal=q2='histogram_quantile(0.9, sum by (instance, le) (rate(http_request_duration_seconds_bucket[5m]))) > 0.4' \
  --from-literal=q3='sum(rate(http_request_duration_seconds_sum[5m])) / sum(rate(http_request_duration_seconds_count[5m]))' \
  --from-literal=q4='sum(rate(http_request_duration_seconds_bucket{le="0.25"}[5m])) / sum(rate(http_request_duration_seconds_count[5m]))' \
  --from-literal=q5='histogram_quantile(0.9, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))' \
  --dry-run=client -o yaml | kubectl apply -f -
```

Then run `astrona submit -c .`. Each task has its own check, and a failed check prints the reason.
