# Question

Solve this question on: `terminal`

The crew of the starship prepares a report about the last 30 minutes of the three groups of targets `bridge`, `shuttle` and `probe`. The report needs five numbers. Some of them come from a range selector and some need a subquery. Write one PromQL expression for each task. Test each expression first with the query helper in the `shuttle` pod:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPR'
```

The helper evaluates at Unix time 1767229200, the time of the newest sample. Use that time for every task. Prometheus has one hour of stored data, one sample every 15 seconds, and it scrapes nothing.

The metrics are the gauge `disk_used_bytes` with the labels `job`, `instance` and `mountpoint`, the gauge `queue_depth` with the labels `job` and `instance`, the counter `http_requests_total` with the labels `job`, `instance`, `method` and `status`, and `up` with the labels `job` and `instance`. The instance `probe-1:9100` stopped reporting at Unix time 1767228600.

1. Store in `q1` an expression for the highest disk usage of every probe disk in the last 30 minutes. The result has one series for each instance, and it includes the probe that stopped reporting.
2. Store in `q2` an expression that returns a result only for the instance `probe-1:9100` of the job `probe`, because it sent no `up` sample in the last 10 minutes. The result must carry the labels `job` and `instance`.
3. Store in `q3` an expression for the standard deviation of the total queue depth of each job over the last 30 minutes, sampled once per minute.
4. Store in `q4` an expression for the highest one-minute rate of responses with the status 500 that each job reached in the last 30 minutes, sampled once per minute. Add the rates of the series of a job together.
5. Store in `q5` an expression for the lowest number of targets that were up at one moment in each job in the last 30 minutes, sampled once per minute. Count the targets with `up`.

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

Apply it with `kubectl apply -f configmap-answers.yaml`. You can also edit the ConfigMap with `kubectl -n starfleet edit configmap answers`. The grader checks the functions that each expression uses, runs it and a reference expression at the required time, and compares the labels and the values of the results.
