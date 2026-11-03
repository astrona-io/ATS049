---
draft: true
exam_objectives:
- Selecting Data
---
# Selectors, Matchers And The Series Model

Every PromQL expression starts by selecting data. Before you can calculate a rate, add up a counter or draw a graph, you must name exactly which time series you mean. A selector that is too wide pulls in series that do not belong in the answer. A selector that is too narrow silently leaves some out, and the final number is wrong without any error message.

This topic teaches the selector from the bottom up. You learn what Prometheus stores, how a metric name and a set of labels identify one series, how the four label matchers narrow a selection, which types an expression can return, and how to count a result so that you can prove a selector picked the population you intended.

The topic has three parts. The first part shows the series model: samples, metric names, labels and what one line of output means. The second part covers the four matchers `=`, `!=`, `=~` and `!~`, the rules for regular expressions and empty values, and selection by metric name. The third part covers the four expression types, range selectors with their duration units, and counting a result with `count` and `count by`.

## Learning objectives

After this topic you can:

- Explain what a time series is and which parts of it identify it: the metric name and the set of label pairs.
- Write selectors with the four matchers `=`, `!=`, `=~` and `!~`, and predict which series each one selects.
- Explain that a regular expression matcher is fully anchored, and that a matcher for an empty value also selects series that do not have the label.
- Explain why a selector needs at least one matcher that cannot match the empty string, and select by metric name with `__name__`.
- Name the four PromQL types (instant vector, range vector, scalar and string) and write a range selector with a valid duration.
- Count the series a selector returns with `count` and `count by`, and use the count to check a selection.

## Before you start

You need to be able to read a metric exposition line such as `http_requests_total{method="GET"} 10` and to run commands in a terminal. You do not need to know any PromQL function yet.

Your playground is a single-node `kind` cluster (a Kubernetes cluster that runs inside a container) with one namespace, `starfleet`. It runs two workloads:

- `prometheus`: a Prometheus server, version 3.5.5. It does not scrape anything. It starts from a data block that was generated and backfilled before the server started, so the data is identical every time you start the playground.
- `shuttle`: a pod that holds a small query helper, `/tools/pq.py`. The helper sends one query to the Prometheus HTTP API and prints the result as plain text.

The data covers one hour, from `2026-01-01T00:00:00Z` (Unix time 1767225600) to `2026-01-01T01:00:00Z` (Unix time 1767229200), with one sample every 15 seconds. There are 68 series. The helper evaluates every query at Unix time 1767229200, the last sample, unless you pass another time. The data describes a small example system:

| Metric | Labels besides `job` and `instance` | What it describes |
| --- | --- | --- |
| `up` | none | One series per target: `bridge-0`, `bridge-1`, `shuttle-0`, `probe-0` and `probe-1` |
| `http_requests_total` | `method`, `status` | Request counters of the `bridge` and `shuttle` jobs |
| `queue_depth` | none | Gauges for the `bridge` and `shuttle` jobs |
| `disk_used_bytes`, `disk_total_bytes` | `mountpoint` | Disk gauges of the `probe` job |
| `temperature_celsius` | `sensor` | A temperature gauge of the `probe` job |
| `node_cpu_seconds_total` | `cpu`, `mode` | CPU time counters of the `probe` job |
| `http_request_duration_seconds_bucket`, `_sum`, `_count` | `handler`, `le` (bucket only) | A histogram for the `bridge` job |
| `process_start_time_seconds`, `backup_last_success_timestamp_seconds` | none | Timestamps stored as values |
| `build_info`, `team_info` | `version` or `team` | Constant information series with the value 1 |
| `error_budget_ratio` | none | One series per job with a fixed value |

Every command in the parts has the same form. It runs the helper inside the `shuttle` pod and passes one expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

The helper prints one line per series: the metric name, the labels in alphabetical order inside braces, and the value. A scalar prints as `scalar 5`, a result without series prints `(empty result)`, and an error prints `error` with the error type and message. A range vector prints the series line followed by one indented `timestamp value` line for each sample. The options `--time UNIX`, `--now` and `--range START END STEP` change the evaluation time, and they are explained where they are first used.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
