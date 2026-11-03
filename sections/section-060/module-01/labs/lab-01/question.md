# Question

Solve this question on: `terminal`

The `bridge` service has two instances, and the crew of the `shuttle` needs latency numbers for the `/orders` handler from the histogram `http_request_duration_seconds`.

Prometheus holds one hour of generated data. Evaluate every expression at Unix time 1767229200 unless the task names another time; that is the default time of the query helper.

1. Estimate the 0.9 quantile of the request duration for each instance, from the rate of the buckets over 5 minutes. The result must have two series that carry only the label `instance`.

2. Estimate the 0.9 quantile of the request duration for the whole service (both instances together), with 5-minute bucket rates. The result must be one series without labels.

3. Repeat the fleet 0.9 quantile with a 5-minute window, but evaluate it at Unix time 1767227475, when the window contains the restart of `bridge-1`. The result must be one series without labels.

4. Find the number of observations of `bridge-0:8080` that took more than 0.25 seconds and at most 0.5 seconds since the process started, from the raw buckets. The result must be one series with the value 4800.

Test each expression with the query helper first:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '<expression>'
```

Store the expressions in the ConfigMap `answers` in the namespace `starfleet`, one key per task: `q1` for the first task, `q2` for the second, and so on. The key holds the expression text only. The grader reads each key, runs your expression and a reference expression at the same time, and compares the series and their values. One command writes the whole ConfigMap, so repeat the keys you already wrote when you add a new one:

```sh
kubectl -n starfleet create configmap answers --from-literal=q1='<expression 1>' --from-literal=q2='<expression 2>' --dry-run=client -o yaml | kubectl apply -f -
```

You can also change a single key with `kubectl -n starfleet edit configmap answers`.
