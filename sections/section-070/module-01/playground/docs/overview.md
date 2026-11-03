# Overview: time, timestamp And Age Of An Event (Playground)

This is a **playground**, not a lab. It starts a fresh single-node `kind` cluster with a Prometheus server that holds a fixed dataset, and then waits. There is no task, no `astrona submit` and no pass or fail. Run queries, change them, `astrona destroy`, start over.

## What's in the box

- A Prometheus server (version 3.5.5) in the namespace `starfleet`. It started from a stored block of samples. It scrapes nothing and has no rules, so the data never changes. The default lookback delta of 5 minutes applies.
- The dataset: one hour of samples, one every 15 seconds, from Unix time 1767225600 (2026-01-01T00:00:00Z) to 1767229200 (01:00:00Z). The newest sample of every series is at 1767229200.
- A pod named `shuttle` in `starfleet` with a query helper at `/tools/pq.py`.

| Series | Labels | What it holds |
| --- | --- | --- |
| `up` | `job`, `instance` | 1 for all five instances; `shuttle-0` is 0 from 1767228000 to 1767228585; `probe-1` has no sample after 1767228600 |
| `http_requests_total` | `job`, `instance`, `method`, `status` | Counters for `bridge-0`, `bridge-1` and `shuttle-0`; `bridge-1` restarts at 1767227400 |
| `queue_depth` | `job`, `instance` | Gauges: a triangle wave, a step and a ramp |
| `disk_used_bytes`, `disk_total_bytes` | `job`, `instance`, `mountpoint` | Disk gauges for the two `probe` instances |
| `temperature_celsius` | `job`, `instance`, `sensor` | Linear gauges for the two `probe` instances |
| `node_cpu_seconds_total` | `job`, `instance`, `cpu`, `mode` | CPU counters for the two `probe` instances |
| `http_request_duration_seconds_bucket`, `_sum`, `_count` | `job`, `instance`, `handler`, `le` | A classic histogram for `bridge-0` and `bridge-1` |
| `process_start_time_seconds` | `job`, `instance` | Start time of each process; `bridge-1` moves to 1767227400 when it restarts |
| `backup_last_success_timestamp_seconds` | `job`, `instance` | Time of the last successful backup; `probe-0` stops refreshing after 1767227400 |
| `build_info`, `team_info` | `job`, `instance`, `version` or `team` | Constant 1, for labels |
| `error_budget_ratio` | `job` | 0.02 for `bridge`, 0.1 for `shuttle` |

## The query helper

Run it from your machine. Without an option it evaluates at 1767229200:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up' --time 1767228300
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up' --now
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up' --range 1767228000 1767228600 60
```

The output has one line per series: `name{label="value", ...} value`, with the labels sorted by name. A scalar prints as `scalar 5`, an empty result as `(empty result)`, and an error as `error <type>: <message>`. `--now` uses the current time of the server, so most queries return an empty result, because the newest sample is older than the lookback delta. Add `--json` to print the raw API response.

To use the Prometheus web interface, run `kubectl -n starfleet port-forward svc/prometheus 9090:9090` and open `http://127.0.0.1:9090`. Set the evaluation time in the interface to a time inside the dataset.

## Ideas to try

- Run `time()` with `--time` set to three different values and then with `--now`. Predict each result first.
- Compute `time() - timestamp(up)` at several times between 1767229185 and 1767229500. At which time does `probe-0` disappear from the result?
- Compute the uptime of every process at 1767227385 and at 1767227400. What changes for `bridge-1`?
- Find the first evaluation time at which `time() - backup_last_success_timestamp_seconds > 900` returns `probe-0`.
- Express the uptime of `bridge-0` in days and compare the digits with a hand calculation.
- Write the limit of an overdue alert for `shuttle-0` that never fires during its normal refresh sawtooth.
