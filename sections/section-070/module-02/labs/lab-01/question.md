# Question

Solve this question on: `terminal`

Prometheus in the namespace `starfleet` holds the `up` series of the `bridge`, `shuttle` and `probe` instances and the start time of each process. Some instances failed, one stopped reporting and one restarted. Write one PromQL expression for each task. Unless a task names another evaluation time, it is evaluated at Unix time 1767229200.

1. Evaluated at Unix time 1767228300, return the `up` series of every target whose last scrape failed. The result must keep the metric name and the value 0.
2. Return the single series that tells you that no sample of `up` exists for the instance `probe-1:9100`. The result must have the value 1 and carry exactly one label, `instance`.
3. Return the processes that restarted during the last hour, using the start time metric. The value must be the number of restarts, and processes without a restart must not appear.
4. Evaluated at Unix time 1767228890, return the `up` series whose newest sample is more than 60 seconds old. The value must be the age of the sample in seconds.
5. Return the `up` series that existed 10 minutes before the evaluation time and do not exist now. Do not write the name of any instance in the expression.

Test an expression first with the query helper, for example:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPRESSION'
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPRESSION' --time 1767228300
```

Store the final expression of each task in the ConfigMap `answers` in the namespace `starfleet`, under the keys `q1` to `q5`. You can edit it with `kubectl -n starfleet edit configmap answers`, or create it with `kubectl -n starfleet create configmap answers --from-literal=q1='EXPRESSION' ... --dry-run=client -o yaml | kubectl apply -f -`. If you use the second form, give every key you have so far in each run, because `kubectl apply` removes keys that are left out.
