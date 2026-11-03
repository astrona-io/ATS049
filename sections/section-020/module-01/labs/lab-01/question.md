# Question

Solve this question on: `terminal`

The `bridge` and `shuttle` services of the starship report request counters, and the crew needs five numbers from them. Write one PromQL expression for each task. Test each expression first with the query helper in the `shuttle` pod:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPR'
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPR' --time 1767227550
```

The helper evaluates at Unix time 1767229200 unless you add `--time`. Use that default time for every task except task 3.

The counter is `http_requests_total` with the labels `job`, `instance`, `method` and `status`. Prometheus has one hour of stored data and scrapes nothing.

1. Store in `q1` an expression for the request rate in requests per second over the last 5 minutes. Return one series per `instance` (with its `job`) by adding up the series with `sum without (method, status)`.
2. Store in `q2` an expression for the number of responses with `status="500"` in the last 10 minutes, one series per `instance`.
3. Store in `q3` an expression for the total request rate of all series of `job="bridge"` over a 5 minute range, evaluated at Unix time 1767227550. One instance of `bridge` restarted shortly before this time. The result must be a single value that is correct across the restart. Do not use a subquery.
4. Store in `q4` an expression for the instant rate of POST requests (the rate from the last two samples, with a `1m` range) of `job="bridge"`, one series per `instance`.
5. Store in `q5` an expression for the share of responses with `status="500"` in the total request rate over the last 5 minutes, one series per `job`.

Store the expressions in the ConfigMap `answers` in the namespace `starfleet`. The ConfigMap already exists and is empty. Save this as `configmap-answers.yaml` and replace each `...` with your expression:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: answers
  namespace: starfleet
data:
  q1: |-
    ...
  q2: |-
    ...
  q3: |-
    ...
  q4: |-
    ...
  q5: |-
    ...
```

Apply it with `kubectl apply -f configmap-answers.yaml`. You can also edit the ConfigMap with `kubectl -n starfleet edit configmap answers`. The grader runs each stored expression and a reference expression at the required time and compares the labels and the values of the results.
