# Question

Solve this question on: `terminal`

The `starfleet` services `bridge`, `shuttle` and `probe` are under review. The review needs five PromQL expressions that combine arithmetic, comparison, matching and set operators. Questions 1 to 4 are evaluated at Unix time `1767229200`, the default time of the query helper. Question 5 is evaluated at `1767228300`, when the target `shuttle-0` is down.

Store each expression as text in the ConfigMap `answers` in the namespace `starfleet`, under the key named in the task. One way is `kubectl -n starfleet edit configmap answers`, adding the keys under `data:`. Test an expression first with the query helper:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up' --time 1767228300
```

1. Key `q1`: the error ratio per job. It is the rate of requests with `status="500"` divided by the rate of all requests, both summed by `job`, with a five-minute `rate` window. The result has one series for each job and only the label `job`.

2. Key `q2`: how many times the error budget each job uses. Divide the result of question 1 by the metric `error_budget_ratio`. The result keeps only the label `job`.

3. Key `q3`: the age in seconds of the last good backup, for the backups that are older than 1800 seconds, but only for instances that are up (the value of `up` is 1). Use `backup_last_success_timestamp_seconds` and `time()`.

4. Key `q4`: the queue depths that are above 26, with the labels `version` from `build_info` and `team` from `team_info` added. The values stay the queue depths.

5. Key `q5`: the number of targets that are down (`up` is 0) as one series without labels.

`kubectl` already points at the cluster. The graders read the expressions from the ConfigMap, run them at the fixed time and compare the series, the labels and the values with the expected result.
