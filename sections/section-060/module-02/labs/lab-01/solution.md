# Solution

The histogram `http_request_duration_seconds` has the series `_bucket` (bounds 0.05, 0.1, 0.25, 0.5, 1 and +Inf), `_sum` and `_count` for `bridge-0:8080` and `bridge-1:8080`.

The steps below test each expression with the query helper, then store it. Values that come from `rate` or a division are approximate here; compare them with your own output.

## Task 1

The mean is the rate of `_sum` divided by the rate of `_count`, with the same window on both sides. `sum by (instance)` on both sides leaves only the label `instance`.

Test it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum by (instance) (rate(http_request_duration_seconds_sum[5m])) / sum by (instance) (rate(http_request_duration_seconds_count[5m]))'
```

You should see two lines with only the label `instance`: about 0.15 for `bridge-0:8080` and about 0.4 for `bridge-1:8080`.

## Task 2

Add the summed rates of all instances in the numerator and in the denominator, then divide once. An average of the two instance means gives about 0.275, which is wrong.

Test it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum(rate(http_request_duration_seconds_sum[5m])) / sum(rate(http_request_duration_seconds_count[5m]))'
```

You should see one line without labels, with a value of about 0.2333.

## Task 3

The bucket `le="0.25"` counts the observations at or under 0.25 seconds. Divide its rate by the rate of the count, and reduce both sides to the label `instance`, so that the labels match.

Test it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum by (instance) (rate(http_request_duration_seconds_bucket{le="0.25"}[5m])) / sum by (instance) (rate(http_request_duration_seconds_count[5m]))'
```

You should see two lines with only the label `instance`: about 0.85 for `bridge-0:8080` and about 0.8 for `bridge-1:8080`.

## Task 4

Requests slower than 1 second are all requests except those in the bucket `le="1"`. Subtract the share at or under 1 second from 1, using summed rates for the whole service.

Test it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '1 - sum(rate(http_request_duration_seconds_bucket{le="1"}[5m])) / sum(rate(http_request_duration_seconds_count[5m]))'
```

You should see one line without labels, with a value of about 0.01 (3 of 300 requests per step).

## Store the answers

Write all expressions in one command:

```sh
kubectl -n starfleet create configmap answers \
  --from-literal=q1='sum by (instance) (rate(http_request_duration_seconds_sum[5m])) / sum by (instance) (rate(http_request_duration_seconds_count[5m]))' \
  --from-literal=q2='sum(rate(http_request_duration_seconds_sum[5m])) / sum(rate(http_request_duration_seconds_count[5m]))' \
  --from-literal=q3='sum by (instance) (rate(http_request_duration_seconds_bucket{le="0.25"}[5m])) / sum by (instance) (rate(http_request_duration_seconds_count[5m]))' \
  --from-literal=q4='1 - sum(rate(http_request_duration_seconds_bucket{le="1"}[5m])) / sum(rate(http_request_duration_seconds_count[5m]))' \
  --dry-run=client -o yaml | kubectl apply -f -
```

Then run `astrona submit -c .`. Each task has its own check, and a failed check prints the reason.
