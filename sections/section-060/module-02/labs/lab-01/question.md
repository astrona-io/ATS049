# Question

Solve this question on: `terminal`

The `bridge` service reports its `/orders` latency in the histogram `http_request_duration_seconds`, and the `shuttle` team needs mean durations and the share of fast requests.

Prometheus holds one hour of generated data. Evaluate every expression at Unix time 1767229200 unless the task names another time; that is the default time of the query helper.

1. Calculate the mean request duration of the last 5 minutes for each instance. The result must be two series that carry only the label `instance`.

2. Calculate the mean request duration of the last 5 minutes for the whole service, so that the instance with more requests counts for more. The result must be one series without labels.

3. Calculate the share of requests that took 0.25 seconds or less in the last 5 minutes, for each instance. The result must be two series that carry only the label `instance`, with values between 0 and 1.

4. Calculate the share of requests that took more than 1 second in the last 5 minutes, for the whole service. The result must be one series without labels, with a value between 0 and 1.

Test each expression with the query helper first:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '<expression>'
```

Store the expressions in the ConfigMap `answers` in the namespace `starfleet`, one key per task: `q1` for the first task, `q2` for the second, and so on. The key holds the expression text only. The grader reads each key, runs your expression and a reference expression at the same time, and compares the series and their values. One command writes the whole ConfigMap, so repeat the keys you already wrote when you add a new one:

```sh
kubectl -n starfleet create configmap answers --from-literal=q1='<expression 1>' --from-literal=q2='<expression 2>' --dry-run=client -o yaml | kubectl apply -f -
```

You can also change a single key with `kubectl -n starfleet edit configmap answers`.
