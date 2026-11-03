# Question

Solve this question on: `terminal`

The starfleet operations team needs five numbers for a status board, and each number is one PromQL expression. Prometheus runs in the namespace `starfleet` with a fixed dataset: one hour of samples every 15 seconds, from Unix time `1767225600` to `1767229200`. Nothing is scraped. The default evaluation time of the helper is `1767229200`.

Write 5 PromQL expressions. Each answer is one expression, and the grader runs it at the time that the task names and compares the labels and the values of the result with the required result.

1. **Answer `q1`.** Write an expression that returns the request rate in requests per second for each `job`, calculated over the last 5 minutes. The result must have the label `job` and no other label. Evaluate at the default time.
2. **Answer `q2`.** Write an expression that returns the CPU time per second for each `instance` and each `mode`, summed over all cores, calculated over the last 5 minutes. The result must have the labels `instance` and `mode` only. Evaluate it at Unix time `1767228600`, which is when both probe targets have samples. Test it with `--time 1767228600`.
3. **Answer `q3`.** Write an expression that returns how many series each metric name has for the job `bridge`. The result must have the label `__name__` and no other label. Evaluate at the default time.
4. **Answer `q4`.** Write an expression that returns the number of targets that are down for each `job`. Jobs without a failed target must not appear in the result. Evaluate it at Unix time `1767228300`. Test it with `--time 1767228300`.
5. **Answer `q5`.** Write an expression that returns the request rate over the last 5 minutes with the label `instance` removed and every other label kept. Use the clause that names the removed label. Evaluate at the default time.

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
