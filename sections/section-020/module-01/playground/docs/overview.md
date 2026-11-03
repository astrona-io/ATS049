# Overview: Counters, rate And increase (Playground)

This is a playground, not a lab. It starts a Prometheus server with a fixed dataset and a helper pod, and then waits. There is no task, no `astrona submit` and no pass or fail. Run queries, change them, `astrona destroy`, start over.

## What is in the box

- A single-node `kind` cluster. `kubectl` is already pointed at it.
- One Prometheus server (version 3.5.5) in the namespace `starfleet`. It scrapes nothing and has no rules. It starts with one hour of generated samples: one sample every 15 seconds, from Unix time 1767225600 (2026-01-01T00:00:00Z) to 1767229200 (01:00:00Z). The default lookback is 5 minutes.
- A pod `shuttle` (a Deployment) with the query helper `/tools/pq.py`.

## The dataset for counters

`http_requests_total` has ten series. Each grows by a constant amount in every 15 second step.

| Instance | Method | Status | Increase per step | Per second |
| --- | --- | --- | --- | --- |
| `bridge-0:8080` | GET | 200 | 150 | 10 |
| `bridge-0:8080` | POST | 200 | 30 | 2 |
| `bridge-0:8080` | GET | 500 | 6 | 0.4 |
| `bridge-0:8080` | POST | 500 | 3 | 0.2 |
| `bridge-1:8080` | GET | 200 | 120 | 8 |
| `bridge-1:8080` | POST | 200 | 15 | 1 |
| `bridge-1:8080` | GET | 500 | 3 | 0.2 |
| `bridge-1:8080` | POST | 500 | 0 | 0 |
| `shuttle-0:8080` | GET | 200 | 60 | 4 |
| `shuttle-0:8080` | GET | 500 | 15 | 1 |

The labels `job` are `bridge` for the first eight series and `shuttle` for the last two. The instance `bridge-1:8080` restarts at Unix time 1767227400: all its counters drop to 0 and grow again from 0. The other series never reset.

## Run a query

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'rate(http_requests_total[5m])'
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'rate(http_requests_total[5m])' --time 1767227550
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'http_requests_total' --range 1767227385 1767227415 15
```

The helper evaluates at Unix time 1767229200 unless you give `--time`. It prints one line per series as `name{label="value", ...} value`, sorted, with `{...}` only when the function dropped the name. A scalar prints as `scalar 5`, an empty result as `(empty result)` and an error as `error <type>: <message>`. A range query prints the series line followed by one `  <unix time> <value>` line per step. Add `--now` to evaluate at the real current time: the result is empty, because the newest sample is much older than 5 minutes.

Optional: open the Prometheus web interface with `kubectl -n starfleet port-forward svc/prometheus 9090:9090` and browse to `http://127.0.0.1:9090`. Set the evaluation time of the graph to 2026-01-01 01:00:00 UTC.

You need `kubectl` and `python3` on your machine.

## Ideas to try

- Predict `rate()` and `increase()` of each series for a 5 minute range at the default time from the table, then run the query and compare.
- Count the samples a range holds with `count_over_time(...[R])` for `R` of `15s`, `30s`, `1m` and `5m`, and find the smallest range for which `rate()` returns a value.
- Run `rate()`, `increase()` and `irate()` on `bridge-1:8080` at the times 1767227385, 1767227400, 1767227415 and 1767227550 and describe what changes across the restart.
- Compare `delta()`, `increase()` and `rate()` on a `bridge-1:8080` counter at 1767227550.
- Compare `sum(rate(http_requests_total{job="bridge"}[5m]))` with `rate(sum(http_requests_total{job="bridge"})[5m:15s])` at 1767227550.
- Group with `sum by (job)`, `sum by (status)` and `sum without (instance, method)` and write down which labels survive.
- Compute the share of 500 responses per job with a division of two `sum by (job)` expressions.
