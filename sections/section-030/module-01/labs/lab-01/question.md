# Question

Solve this question on: `terminal`

The crew of the starship needs four numbers about the queues and the temperatures that `bridge`, `shuttle` and `probe` report. Write one PromQL expression for each task. Test each expression first with the query helper in the `shuttle` pod:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPR'
```

The helper evaluates at Unix time 1767229200, the time of the newest sample. Use that time for every task. Prometheus has one hour of stored data, one sample every 15 seconds, and it scrapes nothing.

The gauge `queue_depth` has the labels `job` and `instance`. The gauge `temperature_celsius` has the labels `job`, `instance` and `sensor`. The instance `probe-1:9100` stopped reporting at Unix time 1767228600.

1. Store in `q1` an expression for the lowest queue depth that each `queue_depth` series reached in the last 10 minutes. The result has one series for each instance.
2. Store in `q2` an expression for the 0.9 quantile of the CPU temperature over the last 10 minutes, for every series that has samples in that window.
3. Store in `q3` an expression for the standard deviation of the queue depth over the last 5 minutes, for the series of the job `bridge` only.
4. Store in `q4` an expression for the newest temperature that each `temperature_celsius` series reported within the last 15 minutes. The result must include the probe that stopped reporting, and it must keep the metric name.

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
```

Apply it with `kubectl apply -f configmap-answers.yaml`. You can also edit the ConfigMap with `kubectl -n starfleet edit configmap answers`. The grader runs each stored expression and a reference expression at the required time and compares the labels and the values of the results.
