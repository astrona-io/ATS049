# Solution

The histogram `http_request_duration_seconds` has the buckets 0.05, 0.1, 0.25, 0.5, 1 and +Inf for the instances `bridge-0:8080` and `bridge-1:8080`.

The steps below test each expression with the query helper, then store it. Values that come from `rate` or a division are approximate here; compare them with your own output.

## Task 1

Take the rate of the buckets, add them per instance while `le` stays in the `by` clause, and pass the result to `histogram_quantile`. Dropping `le` gives an empty result.

Test it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'histogram_quantile(0.9, sum by (instance, le) (rate(http_request_duration_seconds_bucket[5m])))'
```

You should see two lines with only the label `instance`, with values of about 0.375 for `bridge-0:8080` and about 0.4167 for `bridge-1:8080`.

## Task 2

Add the bucket rates of both instances with `sum by (le)`, then take the quantile once. An average of the two instance quantiles gives about 0.3958, which is not the value of the whole service.

Test it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'histogram_quantile(0.9, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))'
```

You should see one line without labels, with a value of about 0.3929.

## Task 3

The same expression works across the counter reset, because `rate` treats a drop of a counter as a reset. Use the window `[5m]`, because a different window weights the two instances differently.

Test it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'histogram_quantile(0.9, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))' --time 1767227475
```

You should see one line without labels, with a value of about 0.392.

## Task 4

Buckets are cumulative, so the observations between two bounds are the difference of two neighbouring buckets. `ignoring(le)` pairs the series although their `le` labels differ.

Test it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'http_request_duration_seconds_bucket{instance="bridge-0:8080",le="0.5"} - ignoring(le) http_request_duration_seconds_bucket{instance="bridge-0:8080",le="0.25"}'
```

You should see one line with the value 4800 (45600 minus 40800) and the labels `handler`, `instance` and `job`.

## Store the answers

Write all expressions in one command:

```sh
kubectl -n starfleet create configmap answers \
  --from-literal=q1='histogram_quantile(0.9, sum by (instance, le) (rate(http_request_duration_seconds_bucket[5m])))' \
  --from-literal=q2='histogram_quantile(0.9, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))' \
  --from-literal=q3='histogram_quantile(0.9, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))' \
  --from-literal=q4='http_request_duration_seconds_bucket{instance="bridge-0:8080",le="0.5"} - ignoring(le) http_request_duration_seconds_bucket{instance="bridge-0:8080",le="0.25"}' \
  --dry-run=client -o yaml | kubectl apply -f -
```

Then run `astrona submit -c .`. Each task has its own check, and a failed check prints the reason.
