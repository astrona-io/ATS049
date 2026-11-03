# Question

Solve this question on: `terminal`

The probes of the starship report queue depths, disk usage and temperatures, and the crew needs six numbers. Write one PromQL expression for each task. Test each expression first with the query helper in the `shuttle` pod:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPR'
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPR' --time 1767228600
```

The helper evaluates at Unix time 1767229200 unless you add `--time`. Use that default time for tasks 1, 5 and 6, and Unix time 1767228600 for tasks 2, 3 and 4. At 1767228600 both probes still have samples.

The metrics are the gauges `queue_depth`, `disk_used_bytes`, `disk_total_bytes` (labels `job`, `instance`, `mountpoint`) and `temperature_celsius` (labels `job`, `instance`, `sensor`), and the counter `http_requests_total`. Prometheus has one hour of stored data and scrapes nothing.

1. Store in `q1` an expression for how much every `queue_depth` series changed over the last 5 minutes, as the difference between the end and the start of the range.
2. Store in `q2` an expression for the number of seconds until each disk is full, if it keeps filling at the speed of the last 15 minutes: the free bytes (`disk_total_bytes` minus `disk_used_bytes`) divided by the slope of `disk_used_bytes`.
3. Store in `q3` an expression for the temperature of each probe 30 minutes (1800 seconds) after the evaluation time, predicted from the last 10 minutes.
4. Store in `q4` an expression that returns only the disks that are predicted to be above `disk_total_bytes` 24 hours after the evaluation time, predicted from the last hour.
5. Store in `q5` an expression that returns only the `http_requests_total` series that had at least one counter reset in the last hour.
6. Store in `q6` an expression for how many times every `queue_depth` series changed its value in the last 10 minutes.

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
  q6: |-
    ...
```

Apply it with `kubectl apply -f configmap-answers.yaml`. You can also edit the ConfigMap with `kubectl -n starfleet edit configmap answers`. The grader runs each stored expression and a reference expression at the required time and compares the labels and the values of the results.
