# Question

Solve this question on: `terminal`

The `bridge` and `shuttle` instances report request counters, queue depths and info metrics with their version and team. A review needs five PromQL expressions that pair series from different vectors. Every expression has a fixed evaluation time. Questions 1 to 3 use `1767229200`, the default time of the query helper. Questions 4 and 5 use `1767228300`, a time at which the target `shuttle-0` is down (`up` is 0).

Store each expression as text in the ConfigMap `answers` in the namespace `starfleet`, under the key named in the task. One way is `kubectl -n starfleet edit configmap answers`, adding the keys under `data:`. Test an expression first with the query helper, for example:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up' --time 1767228300
```

1. Key `q1`: for every combination of `instance` and `method`, the sum of the counter with status `200` and the counter with status `500` of `http_requests_total`. The result keeps the labels `instance`, `job` and `method`, and has five series.

2. Key `q2`: the metric `queue_depth` with the label `version` added. The version comes from `build_info`. The values stay the queue depths.

3. Key `q3`: the counters of `http_requests_total` with the status `500`, with the label `team` added from `team_info`. The values stay the counter values and the result has five series.

4. Key `q4`: the series of `queue_depth` that belong to targets that are down at the evaluation time. Use `up` as the test. The series keep their names and values.

5. Key `q5`: the series of `queue_depth` that do not belong to targets that are down at the evaluation time. The series keep their names and values.

`kubectl` already points at the cluster. The graders read the expressions from the ConfigMap, run them at the fixed time and compare the series, the labels and the values with the expected result.
