# Overview: Selectors, Matchers And The Series Model (Playground)

This is a playground, not a lab. It starts a Prometheus server with a fixed dataset and a query helper, and then waits. There is no task, no `astrona submit` and no pass or fail. Run queries, change them, `astrona destroy` the environment and start again.

## What is in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` already points at it.
- The namespace `starfleet` with two Deployments:
  - `prometheus`: Prometheus 3.5.5. It scrapes nothing and has no rules. It starts from a data block that an init container generates and backfills with `promtool tsdb create-blocks-from openmetrics`. The default lookback delta of 5 minutes applies.
  - `shuttle`: a pod that holds the query helper `/tools/pq.py`.
- One hour of data, with one sample every 15 seconds, from Unix time 1767225600 (`2026-01-01T00:00:00Z`) to 1767229200 (`2026-01-01T01:00:00Z`). There are 68 series.

## The dataset

| Metric | Series | What it holds |
| --- | --- | --- |
| `up` | 5 | 1 for every target. `shuttle-0` is 0 from 1767228000 to 1767228585. `probe-1` has no sample after 1767228600 |
| `http_requests_total` | 10 | Counters with `method` and `status`. `bridge-1` restarts at 1767227400 and its counters start again from 0 |
| `queue_depth` | 3 | Gauges: a triangle wave (`bridge-0`), a step from 5 to 25 at 1767227400 (`bridge-1`), a ramp (`shuttle-0`) |
| `disk_used_bytes`, `disk_total_bytes` | 4 | Disk gauges of the `probe` job with `mountpoint="/"` |
| `temperature_celsius` | 2 | Temperature of the `probe` job with `sensor="cpu"` |
| `node_cpu_seconds_total` | 12 | CPU time of the `probe` job with `cpu` and `mode` |
| `http_request_duration_seconds_bucket`, `_sum`, `_count` | 16 | A classic histogram of the `bridge` job with `handler="/orders"` |
| `process_start_time_seconds`, `backup_last_success_timestamp_seconds` | 8 | Unix timestamps stored as values |
| `build_info`, `team_info` | 6 | Constant series with the value 1 and one information label |
| `error_budget_ratio` | 2 | A fixed value for the jobs `bridge` and `shuttle` |

The jobs are `bridge` (instances `bridge-0:8080`, `bridge-1:8080`), `shuttle` (`shuttle-0:8080`) and `probe` (`probe-0:9100`, `probe-1:9100`).

## The query helper

Every query runs inside the `shuttle` pod:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

| Option | Meaning |
| --- | --- |
| none | Instant query at Unix time 1767229200, the last sample |
| `--time UNIX` | Instant query at that time |
| `--now` | Instant query without a time, so the server uses its own clock. This returns nothing for selectors, because the data is old |
| `--range START END STEP` | Range query. START and END are Unix seconds, STEP is in seconds |
| `--json` | Print the raw API response. Put it before the expression |

Output: one line per series as `name{labels} value` with the labels sorted by name, `scalar 5` for a scalar, `(empty result)` for an empty result and `error TYPE: MESSAGE` for an error. A range vector or range query prints the series line followed by indented `timestamp value` lines.

The Prometheus web interface is optional. Forward the port and open `http://127.0.0.1:9090`:

```sh
kubectl -n starfleet port-forward svc/prometheus 9090:9090
```

The web interface evaluates at the current time by default, so choose the evaluation time `2026-01-01 01:00:00` first, or the graphs are empty.

## Ideas to try

- Select the `up` series of one job with `=`, then with `=~`, and compare the counts with `count by (job) (up)`.
- Use `{sensor=""}` and `{sensor!=""}` on `temperature_celsius` and on `up`, and explain each result.
- Find every metric name that contains `duration` with `count by (__name__) ({__name__=~".*duration.*"})`.
- Try `{job=~".*"}` and `{job=~".+"}` and read the error.
- Select `http_requests_total{job="bridge"}[1m]` and count the samples in each series. Change the duration to `[1m1s]` and `[45s]`.
