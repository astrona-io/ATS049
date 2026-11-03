# Overview: topk, bottomk, quantile, count_values And Statistics (Playground)

This is a playground, not a lab. It starts a fresh Kubernetes cluster with a Prometheus server that holds a fixed dataset, and then waits. There is no task, no `astrona submit` and no pass or fail. Run queries, change them, `astrona destroy`, start over.

## What is in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it.
- Namespace `starfleet` with a Prometheus server (version 3.5.5, service `prometheus` on port 9090). It scrapes nothing and has no rules. Its storage holds a backfilled block with one hour of samples, one sample every 15 seconds, from Unix time `1767225600` (2026-01-01T00:00:00Z) to `1767229200`. The default evaluation time is the last sample, `1767229200`.
- A pod `shuttle` (deployment `shuttle`) that runs the query helper `/tools/pq.py`.

## The dataset

The dataset has 68 series. The names `bridge-0`, `bridge-1`, `shuttle-0`, `probe-0` and `probe-1` are targets, and every series has the labels `job` and `instance`.

| Metric | Series | What it contains |
| --- | --- | --- |
| `up` | 5 | 1 for every target, except `shuttle-0` is 0 from `1767228000` to `1767228585`, and `probe-1` has no samples after `1767228600` |
| `http_requests_total` | 10 | Counters by `method` and `status` for `bridge-0`, `bridge-1` and `shuttle-0`. `bridge-1` restarts at `1767227400` and its counters return to 0 |
| `queue_depth` | 3 | Gauges: `bridge-0` is a wave between 10 and 30, `bridge-1` is 5 and then 25 from `1767227400`, `shuttle-0` is 0 and then grows by 2 per sample from `1767227100` |
| `node_cpu_seconds_total` | 12 | Counters by `cpu` (0, 1) and `mode` (idle, user, system) for `probe-0` and `probe-1` |
| `disk_used_bytes`, `disk_total_bytes` | 4 | Disk gauges of the probes, with the label `mountpoint` |
| `temperature_celsius` | 2 | CPU temperature of the probes, with the label `sensor` |
| `http_request_duration_seconds_bucket`, `_sum`, `_count` | 16 | Histogram of the handler `/orders` of the two bridge targets, with `le` buckets 0.05, 0.1, 0.25, 0.5, 1 and `+Inf` |
| `process_start_time_seconds`, `backup_last_success_timestamp_seconds` | 8 | Timestamps in Unix seconds |
| `build_info`, `team_info`, `error_budget_ratio` | 8 | Constant information series |

Prometheus ignores a sample that is older than 5 minutes (the lookback delta), so `probe-1` is missing from instant queries at the default time. Querying with `--now` returns an empty result, because the newest sample is far older than 5 minutes.

## The query helper

Run it with `kubectl`. The helper evaluates the expression and prints one line per series in the form `name{label="value"} value`, sorted as text:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up' --time 1767228300
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up' --now
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up' --range 1767227400 1767228000 60
```

A scalar prints as `scalar 5`, an empty result as `(empty result)` and an error as `error <type>: <message>`. A range query prints each series followed by lines with the Unix time and the value. Without a time option the helper uses `1767229200`.

You can open the Prometheus web interface with `kubectl -n starfleet port-forward svc/prometheus 9090:9090` and browse to `http://127.0.0.1:9090`. Set the evaluation time in the interface to the times above, or you see no data.

## Ideas to try

- Run `topk(2, queue_depth)` and `bottomk by (job) (1, queue_depth)` and compare the labels with `max by (job) (queue_depth)`.
- Rank `sum by (instance) (rate(http_requests_total[5m]))` with `topk`, then run `topk(1, queue_depth)` at `--time 1767225900` and at the default time.
- Run `quantile(0.5, ...)`, `quantile(0.25, ...)` and `quantile by (job) (0.5, ...)` on `queue_depth` and predict the interpolated values.
- Compare `stddev(queue_depth{job="bridge"})` with `stddev(queue_depth)`.
- Run `count_values("state", up)` at `--time 1767228300`.
- Calculate the average request duration as the rate of `_sum` over the rate of `_count`, with and without `avg`, and compare the two values.
- Find the failing target at `--time 1767228300` with `avg(up)`, `min by (job) (up)` and `up == 0`.
