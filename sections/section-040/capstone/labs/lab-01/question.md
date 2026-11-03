# Question

Solve this question on: `terminal`

The starfleet operations team needs a fleet report from one Prometheus server, and each line of the report is one PromQL expression. Prometheus runs in the namespace `starfleet` with a fixed dataset: one hour of samples every 15 seconds, from Unix time `1767225600` to `1767229200`. Nothing is scraped. The default evaluation time of the helper is `1767229200`.

Write 5 PromQL expressions. Each answer is one expression, and the grader runs it at the time that the task names and compares the labels and the values of the result with the required result.

1. **Answer `q1`.** Write an expression that returns the share of requests with status `500` for each `job`, as a ratio between 0 and 1. The result has the label `job` only. Do not average per-instance ratios and do not use `avg`. Evaluate at the default time.
2. **Answer `q2`.** Write an expression that returns, for each `job`, the lowest `up` value of its targets, so that one failed target shows as `0`. Evaluate it at Unix time `1767228300`. Test it with `--time 1767228300`.
3. **Answer `q3`.** Write an expression that returns the single instance with the highest request rate, with the label `instance`. Evaluate at the default time.
4. **Answer `q4`.** Write an expression that returns the standard deviation of `queue_depth` for each `job`. Evaluate at the default time.
5. **Answer `q5`.** Write an expression that returns the number of different `cpu` values for each `instance` of `node_cpu_seconds_total`. The result has the label `instance` only. Evaluate it at Unix time `1767228600`. Test it with `--time 1767228600`.

## How to test and store an answer

Test an expression with the query helper that runs in the `shuttle` pod. Add `--time <unix seconds>` when the task gives another time:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

Store each answer as one key in the ConfigMap `answers` in the namespace `starfleet`. The key names are `q1`, `q2` and so on. Write all your answers so far in one command, because the command replaces the whole set of keys:

```sh
kubectl -n starfleet create configmap answers --from-literal=q1='sum(up)' --dry-run=client -o yaml | kubectl apply -f -
```

Add one more `--from-literal=qN='...'` argument for each further answer. Use double quotes inside an expression and single quotes around it. You can also change the keys with `kubectl -n starfleet edit configmap answers`.
