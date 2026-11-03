# Overview: Subqueries And Nested Time Aggregation (Playground)

This is a **playground**, not a lab. It starts a Prometheus server with a fixed dataset and a helper pod, and then waits. There is no task, no `astrona submit` and no pass or fail. Run queries, compare them with your predictions, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it.
- A Prometheus server (version 3.5.5) in the namespace `starfleet`. It scrapes nothing and has no rules. It starts with one hour of stored samples, one every 15 seconds, from Unix time 1767225600 (2026-01-01T00:00:00Z) to 1767229200 (01:00:00Z), generated from fixed formulas.
- A pod `shuttle` that runs the query helper `/tools/pq.py`.

## The dataset

| Metric | Labels | What it holds |
| --- | --- | --- |
| `up` | `job`, `instance` | 1 for five targets. `shuttle-0:8080` is 0 from 1767228000 to 1767228585. `probe-1:9100` has no sample after 1767228600. |
| `queue_depth` | `job`, `instance` | Gauge. `bridge-0:8080` is a triangle wave between 10 and 30 with a cycle of 10 minutes. `bridge-1:8080` is 5, then 25 from 1767227400. `shuttle-0:8080` is 0 until 1767227100, then rises by 2 per step. |
| `temperature_celsius` | `job`, `instance`, `sensor` | `probe-0:9100` is 20 + 0.1 per step. `probe-1:9100` is 30 - 0.05 per step and ends at 1767228600. |
| `http_requests_total` | `job`, `instance`, `method`, `status` | Ten counters that grow by a constant amount per step. `bridge-1:8080` restarts at 1767227400 and starts again from 0. |
| `disk_used_bytes`, `disk_total_bytes` | `job`, `instance`, `mountpoint` | Gauges of the two probes. |

The dataset also holds `node_cpu_seconds_total`, a histogram `http_request_duration_seconds`, timestamp metrics, `build_info`, `team_info` and `error_budget_ratio`. This playground needs only the first four metrics.

## The query helper

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPR'
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPR' --time 1767228600
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPR' --now
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPR' --range 1767228600 1767229200 15
```

The first form evaluates at Unix time 1767229200. `--time` sets another evaluation time. `--now` uses the server clock, and it returns an empty result because the newest sample is far older than the 5 minute lookback. `--range` runs a range query with a start, an end and a step in seconds. The output has one line per series, sorted, as `name{label="value", ...} value`. A scalar prints as `scalar 5`, an empty result as `(empty result)`, and an error as `error <type>: <message>`. A range vector prints the series and then one `<unix time> <value>` line per sample.

The Prometheus web interface is optional. Run `kubectl -n starfleet port-forward svc/prometheus 9090:9090` and open `http://127.0.0.1:9090`. Set the evaluation time to 2026-01-01 01:00:00 UTC.

## Practice tasks

- Run `queue_depth[1m:]` and `queue_depth[1m:30s]` and list the times of the points. Then move the evaluation time with `--time` by 10 seconds and see which points change.
- Predict `max_over_time(sum by (job) (queue_depth)[5m:1m])` at `--time 1767227700`, then run it. Compare it with `sum by (job) (max_over_time(queue_depth[5m]))` and explain the difference.
- Find the highest one-minute request rate of each job in the last 10 minutes with `max_over_time(sum by (job) (rate(http_requests_total[1m]))[10m:1m])`.
- Find the lowest number of healthy targets of each job in the last 30 minutes. Compare `min_over_time(sum by (job) (up)[30m:1m])` with `sum by (job) (min_over_time(up[30m]))`.
- Count the points of `queue_depth[1h:15s]`, `queue_depth[1h:1m]` and `queue_depth[10m:5m]` with `count_over_time`.
- Run `rate(sum by (job) (http_requests_total)[10m:1m])` at `--time 1767227700` and compare it with the sum of the per-series rates.
