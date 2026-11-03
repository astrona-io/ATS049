# Question

Solve this question on: `terminal`

The `bridge` service is reviewed before a release, and the `shuttle` team needs a latency report for the `/orders` handler from the histogram `http_request_duration_seconds`.

Prometheus holds one hour of generated data. Evaluate every expression at Unix time 1767229200 unless the task names another time; that is the default time of the query helper.

1. Report the 0.9 quantile of the request duration for each instance over the last 5 minutes. The result must have two series that carry only the label `instance`.

2. Return only the instances whose 0.9 quantile (5-minute rate) is above 0.4 seconds. The result must keep the quantile value and only the label `instance`.

3. Report the mean request duration of the whole service over the last 5 minutes, weighted by requests. The result must be one series without labels.

4. Report the share of requests at or under 0.25 seconds for the whole service over the last 5 minutes. The result must be one series without labels.

5. Report the 0.9 quantile of the whole service with a 5-minute window, evaluated at Unix time 1767227475, when the window contains the restart of `bridge-1`. The result must be one series without labels.

Test each expression with the query helper first:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '<expression>'
```

Store the expressions in the ConfigMap `answers` in the namespace `starfleet`, one key per task: `q1` for the first task, `q2` for the second, and so on. The key holds the expression text only. The grader reads each key, runs your expression and a reference expression at the same time, and compares the series and their values. One command writes the whole ConfigMap, so repeat the keys you already wrote when you add a new one:

```sh
kubectl -n starfleet create configmap answers --from-literal=q1='<expression 1>' --from-literal=q2='<expression 2>' --dry-run=client -o yaml | kubectl apply -f -
```

You can also change a single key with `kubectl -n starfleet edit configmap answers`.
