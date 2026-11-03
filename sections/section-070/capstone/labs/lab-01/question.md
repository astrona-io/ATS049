# Question

Solve this question on: `terminal`

The crew of the `bridge`, `shuttle` and `probe` processes wants one health review of backups and processes in Prometheus, in the namespace `starfleet`. Write one PromQL expression for each task. All tasks are evaluated at Unix time 1767229200.

1. Return the number of minutes since the last successful backup, only for the sources whose last backup is older than 30 minutes.
2. Return the `backup_last_success_timestamp_seconds` series that existed 10 minutes before the evaluation time and do not exist now. Do not write the name of any instance.
3. Return 1, with the label `instance`, if the instance `probe-1:9100` reported no sample of `up` during the last 10 minutes. Use the function that tests a range, not the lookback window.
4. Return the processes that restarted during the last 45 minutes, using the start time metric. The value must be the number of restarts, and processes without a restart must not appear.
5. Return one value without labels: the longest uptime of any process, in days.

Test an expression first with the query helper:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPRESSION'
```

Store the final expression of each task in the ConfigMap `answers` in the namespace `starfleet`, under the keys `q1` to `q5`. You can edit it with `kubectl -n starfleet edit configmap answers`, or create it with `kubectl -n starfleet create configmap answers --from-literal=q1='EXPRESSION' ... --dry-run=client -o yaml | kubectl apply -f -`. If you use the second form, give every key you have so far in each run, because `kubectl apply` removes keys that are left out.
