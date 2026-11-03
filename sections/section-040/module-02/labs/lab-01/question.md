# Question

Solve this question on: `terminal`

The starfleet operations team wants a ranking, a typical value and a weighted ratio from the same dataset. Prometheus runs in the namespace `starfleet` with a fixed dataset: one hour of samples every 15 seconds, from Unix time `1767225600` to `1767229200`. Nothing is scraped. The default evaluation time of the helper is `1767229200`.

Write 6 PromQL expressions. Each answer is one expression, and the grader runs it at the time that the task names and compares the labels and the values of the result with the required result.

1. **Answer `q1`.** Write an expression that returns the two instances with the highest request rate (requests per second over the last 5 minutes). The result must have the label `instance` and no other label. Evaluate at the default time.
2. **Answer `q2`.** Write an expression that returns, for each `job`, the single series of `queue_depth` with the lowest value. The result must keep all labels of the original series, so that you can see which instance it is. Evaluate at the default time.
3. **Answer `q3`.** Write an expression that returns the median of `queue_depth` across all instances, as one series without labels. Evaluate at the default time.
4. **Answer `q4`.** Write an expression that returns how many `up` series have each value. The value must be in a label called `state`. Evaluate it at Unix time `1767228300`. Test it with `--time 1767228300`.
5. **Answer `q5`.** Write an expression that returns the share of requests with status `500` for the whole job `bridge`, as one series without labels. Do not average per-instance ratios. The expression must not contain `avg`. Evaluate at the default time.
6. **Answer `q6`.** Write an expression that returns the average request duration in seconds across all instances, as one series without labels. It must use the `_sum` and `_count` series of `http_request_duration_seconds` and must not contain `avg`. Evaluate at the default time.

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
