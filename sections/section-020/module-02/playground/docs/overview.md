# Overview: Gauges: delta, deriv And predict_linear (Playground)

This is a playground, not a lab. It starts a Prometheus server with a fixed dataset and a helper pod, and then waits. There is no task, no `astrona submit` and no pass or fail. Run queries, change them, `astrona destroy`, start over.

## What is in the box

- A single-node `kind` cluster. `kubectl` is already pointed at it.
- One Prometheus server (version 3.5.5) in the namespace `starfleet`. It scrapes nothing and has no rules. It starts with one hour of generated samples: one sample every 15 seconds, from Unix time 1767225600 (2026-01-01T00:00:00Z) to 1767229200 (01:00:00Z). The default lookback is 5 minutes.
- A pod `shuttle` (a Deployment) with the query helper `/tools/pq.py`.

## The dataset for gauges

| Metric | Series | Behaviour |
| --- | --- | --- |
| `queue_depth` | `bridge-0:8080` | Triangle wave between 10 and 30, period 40 steps (10 minutes). At 1767229200 it is 30 and rising by 1 per step |
| `queue_depth` | `bridge-1:8080` | 5, then 25 from Unix time 1767227400 |
| `queue_depth` | `shuttle-0:8080` | 0 until Unix time 1767227100, then +2 per step (280 at the end) |
| `disk_used_bytes` | `probe-0:9100` | 40,000,000,000 plus 15,000,000 per step (1,000,000 bytes per second) |
| `disk_used_bytes` | `probe-1:9100` | 40,000,000,000 plus 7,500,000 per step (500,000 bytes per second) |
| `disk_total_bytes` | both probes | 100,000,000,000 |
| `temperature_celsius` | `probe-0:9100` | 20 plus 0.1 per step (0.4 degrees per minute) |
| `temperature_celsius` | `probe-1:9100` | 30 minus 0.05 per step (-0.2 degrees per minute) |

The labels `job` are `bridge` for the bridge queues, `shuttle` for the shuttle queue and `probe` for the probes (the disk series also have `mountpoint="/"` and the temperature series `sensor="cpu"`). All series of `probe-1:9100` have no samples after Unix time 1767228600. The playground also holds the counter `http_requests_total` (the instance `bridge-1:8080` restarts at 1767227400 and its counters drop to 0) and the gauge `process_start_time_seconds`.

## Run a query

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'deriv(disk_used_bytes[15m])'
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'predict_linear(disk_used_bytes[1h], 24 * 3600)' --time 1767228600
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'queue_depth' --range 1767228600 1767229200 60
```

The helper evaluates at Unix time 1767229200 unless you give `--time`. It prints one line per series as `name{label="value", ...} value`, sorted, with `{...}` only when the function dropped the name. A scalar prints as `scalar 5`, an empty result as `(empty result)` and an error as `error <type>: <message>`. A range query prints the series line followed by one `  <unix time> <value>` line per step. Add `--now` to evaluate at the real current time: the result is empty, because the newest sample is much older than 5 minutes.

Optional: open the Prometheus web interface with `kubectl -n starfleet port-forward svc/prometheus 9090:9090` and browse to `http://127.0.0.1:9090`. Set the evaluation time of the graph to 2026-01-01 01:00:00 UTC.

You need `kubectl` and `python3` on your machine.

## Ideas to try

- Predict `delta()`, `idelta()` and `deriv()` of each queue for a 5 minute range at the default time, then compare with the query.
- Run `rate()` and `delta()` on `queue_depth{instance="bridge-0:8080"}` at Unix time 1767228750 and explain why they disagree.
- Compute the seconds until each disk is full from the free space and `deriv()`, at the times 1767228600 and 1767229200, and explain why the result at the later time has fewer series.
- Predict the temperature of `probe-0:9100` in 1 hour with `predict_linear()` and with `deriv()` multiplied by 3600, and check that the two agree.
- Change the range of `deriv(queue_depth{instance="shuttle-0:8080"}[R])` from `5m` to `1h` and watch the slope fall.
- Count the falls of a queue with `resets(queue_depth[10m])` and the value changes with `changes(queue_depth[10m])`.
- Count restarts with `changes(process_start_time_seconds[1h])` and with `resets(http_requests_total[1h])`.
