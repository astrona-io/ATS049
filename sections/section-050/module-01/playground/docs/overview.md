# Overview: Arithmetic, Comparison And Precedence (Playground)

This is a playground, not a lab. It starts a Prometheus server with a fixed dataset and waits. There is no task, no `astrona submit` and no pass or fail. Run queries, change them, and compare the result with what you predicted. Run `astrona destroy` and start again when you want a clean state.

## What is in the box

- A single-node `kind` cluster that runs Kubernetes 1.35. `kubectl` points at it.
- A Prometheus server, version 3.5.5, in the namespace `starfleet`. It scrapes nothing and has no rules. It starts with a block of backfilled data.
- A pod `shuttle` that holds the query helper `/tools/pq.py`.

The data covers one hour, from `2026-01-01T00:00:00Z` (Unix 1767225600) to `2026-01-01T01:00:00Z` (Unix 1767229200), with one sample every 15 seconds. The default evaluation time of the helper is 1767229200, the last sample. The lookback delta is the default 5 minutes, so a query without a time at the real current time returns an empty result.

## The dataset

| Metric | Labels | Behaviour |
| --- | --- | --- |
| `up` | `job`, `instance` | 1 for all five targets. `shuttle-0` is 0 from 1767228000 to 1767228585. `probe-1` has no samples after 1767228600. |
| `http_requests_total` | `job`, `instance`, `method`, `status` | Counters with a constant increase. `bridge-1` restarts at 1767227400 and its counters start from 0. |
| `queue_depth` | `job`, `instance` | `bridge-0` is a triangle wave from 10 to 30, `bridge-1` is 5 and then 25, `shuttle-0` is 0 and then rises by 2 per step. |
| `disk_used_bytes`, `disk_total_bytes` | `job`, `instance`, `mountpoint` | Two `probe` disks. Used grows linearly, total is 100,000,000,000. |
| `temperature_celsius` | `job`, `instance`, `sensor` | `probe-0` is 20 plus 0.1 per step, `probe-1` is 30 minus 0.05 per step. |
| `process_start_time_seconds`, `backup_last_success_timestamp_seconds` | `job`, `instance` | Unix timestamps. The backup of `probe-0` stops refreshing after 1767227400. |
| `build_info`, `team_info`, `error_budget_ratio` | `job`, `instance`, `version` or `team` | Constants. |

## The query helper

Run it with `kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'EXPRESSION'`.

| Option | Effect |
| --- | --- |
| none | Instant query at 1767229200 |
| `--time 1767228300` | Instant query at that Unix time |
| `--now` | Instant query at the current time (empty result) |
| `--range START END STEP` | Range query, one line per series and one indented line per step |
| `--json` | Print the raw API response |

The helper prints one line per series as `name{label="value"} value`, with the labels in alphabetical order, `scalar 5` for a scalar, `(empty result)` for an empty result and `error <type>: <message>` for an error. You can also open the Prometheus UI with `kubectl -n starfleet port-forward svc/prometheus 9090:9090`.

## Ideas to try

- Predict the output of `queue_depth * 2`, `queue_depth ^ 2` and `queue_depth % 7`, then run them.
- Compare `queue_depth > 26` with `queue_depth > bool 26` and with `sum(queue_depth > bool 26)`.
- Run `up == 0` at the default time and at `--time 1767228300`.
- Calculate `time() - process_start_time_seconds` and explain the value of `bridge-1`.
- Evaluate `2 ^ 3 ^ 2` and `(2 ^ 3) ^ 2` and explain the difference.
- Build the error ratio per `job` and compare it with the ratio of the totals.
- Divide the 500 counters of `bridge-1` by zero and remove the `NaN` series with a comparison.
