# Overview: Classic Histograms And histogram_quantile (Playground)

This is a **playground**, not a lab. It starts a Prometheus server that holds a fixed, generated dataset, and then waits. There is no task, no `astrona submit` and no pass or fail. Run queries, change them, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster. `kubectl` already points at it.
- A Prometheus server (version 3.5.5) in the namespace `starfleet`. It scrapes nothing and has no rules. It starts with a backfilled data block that an init container builds from generated OpenMetrics text.
- A pod `shuttle` that holds a query helper, `/tools/pq.py`.
- Optional: the Prometheus web interface through `kubectl -n starfleet port-forward svc/prometheus 9090:9090`, then open `http://127.0.0.1:9090`. Set the evaluation time in the interface to the dataset times below.

## The dataset

One hour of samples, one every 15 seconds, from Unix time 1767225600 (2026-01-01T00:00:00Z) to 1767229200. The step number `k` runs from 0 to 240, and the time is 1767225600 plus 15 times `k`. The default evaluation time of the helper is 1767229200, the newest sample. Prometheus looks back 5 minutes for a sample, so a query at the current time returns nothing.

| Metric | Labels | What it holds |
| --- | --- | --- |
| `up` | `job`, `instance` | 1 for five targets; `shuttle-0` is 0 from k=160 to k=199; `probe-1` has no samples after k=200 |
| `http_requests_total` | `job`, `instance`, `method`, `status` | counters with a constant increase per step; `bridge-1` restarts at k=120 |
| `http_request_duration_seconds_bucket`, `_sum`, `_count` | `job="bridge"`, `instance`, `handler="/orders"`, `le` | a classic histogram with bounds 0.05, 0.1, 0.25, 0.5, 1 and +Inf; `bridge-1` restarts at k=120 |
| `queue_depth`, `temperature_celsius`, `disk_used_bytes`, `disk_total_bytes`, `node_cpu_seconds_total` | per instance | gauges and counters for the other lessons |
| `process_start_time_seconds`, `backup_last_success_timestamp_seconds`, `build_info`, `team_info`, `error_budget_ratio` | per instance or job | timestamps and constant values |

The histogram per step (every 15 seconds) adds cumulative observations to the buckets 0.05, 0.1, 0.25, 0.5, 1 and +Inf. For `bridge-0:8080` the numbers are 60, 120, 170, 190, 198 and 200, with 30 seconds of total duration. For `bridge-1:8080` they are 10, 40, 80, 95, 99 and 100, with 40 seconds of total duration. The restart of `bridge-1:8080` is at Unix time 1767227400.

## The query helper

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'http_request_duration_seconds_count'
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPRESSION' --time 1767227475
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPRESSION' --range 1767228000 1767229200 60
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPRESSION' --now
```

The first form evaluates at the default time. The output is one line per series, as `name{label="value", ...} value`, with the labels sorted by name. A scalar prints `scalar <value>`, an empty result prints `(empty result)` and an error prints `error <type>: <message>`. A range query prints each series name and then one line per step with the Unix time and the value.

## Ideas to try

- Select the buckets of `bridge-1` at `--time 1767227385` and at `--time 1767227400` and compare them.
- Compute the 0.5, 0.9 and 0.99 quantiles per instance and for the whole service. Work out each value by hand from the per-step counts first.
- Remove `le` from the `by` clause and watch the result become empty.
- Compare the fleet quantile from `rate` with the fleet quantile from the raw buckets.
- Run the fleet quantile at `--time 1767227475` and at the default time, and explain the small difference.
- Use `--range 1767226800 1767229200 60` to draw the 0.9 quantile over 40 minutes and find the reset.
