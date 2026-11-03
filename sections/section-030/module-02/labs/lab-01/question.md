# Question

Solve this question on: `terminal`

The crew of the starship watches the queues, the request rates and the health of the targets that `bridge`, `shuttle` and `probe` report. Each task asks about a value that Prometheus has to compute first, so each answer needs a subquery. Write one PromQL expression for each task. Test each expression first with the query helper in the `shuttle` pod:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPR' --time 1767229200
```

Prometheus has one hour of stored data, one sample every 15 seconds, from Unix time 1767225600 to 1767229200, and it scrapes nothing. Every task names its own evaluation time. Pass it to the helper with `--time`, because the grader evaluates your expression at that time.

The gauge `queue_depth` has the labels `job` and `instance`. The counter `http_requests_total` has the labels `job`, `instance`, `method` and `status`. The metric `up` has the labels `job` and `instance`. The instance `bridge-1:8080` restarts at Unix time 1767227400, and its counters start again from 0.

1. Store in `q1` an expression for the highest total queue depth that each job reached in the last 5 minutes, sampled once per minute. The result has one series for each job. Evaluation time: 1767227700.
2. Store in `q2` an expression for the highest one-minute request rate that each job reached in the last 10 minutes, sampled once per minute. Add the rates of the series of a job together. Evaluation time: 1767227700.
3. Store in `q3` an expression for the lowest value of `up` that each job had in the last 20 minutes, where a job counts as healthy only if all its series are 1, sampled every 15 seconds. The result has one series for each job. Evaluation time: 1767229200.
4. Store in `q4` an expression for the average total queue depth of each job over the last 30 minutes, sampled once per minute. Evaluation time: 1767229200.

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

Apply it with `kubectl apply -f configmap-answers.yaml`. You can also edit the ConfigMap with `kubectl -n starfleet edit configmap answers`. The grader checks that each expression uses the right over_time function and a subquery, runs it and a reference expression at the required time, and compares the labels and the values of the results.
