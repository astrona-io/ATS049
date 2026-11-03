# Question

Solve this question on: `terminal`

The operations team of the starship needs a status report from Prometheus. It covers disks, request rates across a restart, restarts, a growing queue and an hourly error share. Write one PromQL expression for each task. Test each expression first with the query helper in the `shuttle` pod:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPR'
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPR' --time 1767228600
```

The helper evaluates at Unix time 1767229200 unless you add `--time`. Prometheus has one hour of stored data and scrapes nothing. The instance `bridge-1:8080` restarted at Unix time 1767227400, and its counters started again from 0.

1. Store in `q1` an expression for the number of hours until each disk is full at Unix time 1767228600, if it keeps filling at the speed of the last 15 minutes. Free bytes are `disk_total_bytes` minus `disk_used_bytes`.
2. Store in `q2` an expression for the request rate of `http_requests_total` of `job="bridge"` over a 5 minute range at Unix time 1767227550, one series per `instance`. The result must be correct across the restart. Do not use a subquery.
3. Store in `q3` an expression for the number of counter resets of all `http_requests_total` series in the last hour, one series per `instance`.
4. Store in `q4` an expression for the growth of the `queue_depth` of `job="shuttle"` in items per minute, from the last 5 minutes.
5. Store in `q5` an expression for the share of responses with `status="500"` in all responses over the last hour, as one value.

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
