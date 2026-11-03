# Question

Solve this question on: `terminal`

The `bridge`, `shuttle` and `probe` processes report their start times and their last successful backups to Prometheus in the namespace `starfleet`. Write one PromQL expression for each task below. Unless a task names another evaluation time, it is evaluated at Unix time 1767229200.

1. Return the uptime in seconds of every process that has `process_start_time_seconds`.
2. Return, for every source of `backup_last_success_timestamp_seconds`, the number of minutes since its last successful backup.
3. Return only the sources whose last successful backup is older than 15 minutes. The value of each result must be the age in seconds.
4. Evaluated at Unix time 1767229393, return for every series of `up` the number of seconds between the evaluation time and the stored time of its newest sample.
5. Return the uptime in hours of every process that has been running for less than 2 hours. Processes with a longer uptime must not appear.

Test an expression first with the query helper, for example:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPRESSION'
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPRESSION' --time 1767229393
```

Store the final expression of each task in the ConfigMap `answers` in the namespace `starfleet`, under the keys `q1` to `q5`. You can edit it with `kubectl -n starfleet edit configmap answers`, or create it with `kubectl -n starfleet create configmap answers --from-literal=q1='EXPRESSION' ... --dry-run=client -o yaml | kubectl apply -f -`. If you use the second form, give every key you have so far in each run, because `kubectl apply` removes keys that are left out.
