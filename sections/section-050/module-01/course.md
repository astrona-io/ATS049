---
draft: true
exam_objectives:
- Binary operators
---

# Arithmetic, Comparison And Precedence

A PromQL query rarely stops at a raw metric. A disk gauge in bytes means little until it is divided by the disk size. A queue depth means little until it is compared with a limit. A counter needs a ratio of errors to all requests before it says anything about quality. Binary operators are the part of PromQL that combines two values into a new one, and they appear in almost every real query and in many questions of the Prometheus Certified Associate exam.

This module covers the operators that take two operands and return one result: the arithmetic operators, the comparison operators and the rules that decide which operator runs first. It also covers what a query returns when it divides by zero.

## Learning objectives

After this module you can:

- Apply `+`, `-`, `*`, `/`, `%`, `^` and `atan2` between a scalar and an instant vector, and between two scalars.
- Say which labels survive an arithmetic operation and why the metric name disappears.
- Use a comparison operator as a filter, and use the `bool` modifier to return 0 or 1 instead.
- Explain why a comparison between two scalars must use `bool`.
- Predict the evaluation order of an expression from the precedence table, including the right-associative `^`.
- Write the error ratio `sum(rate(...5xx)) / sum(rate(...all))` and explain why both sides are aggregated first.
- Say what `1 / 0`, `-1 / 0` and `0 / 0` return, and how a comparison removes NaN values from a result.

## Before you start

You need to know what a metric, a label, an instant vector and a scalar are, and how to write a selector such as `up{job="bridge"}`. You do not need to know aggregation in depth. The parts use `sum`, `count` and `rate` only in short examples and explain each one when it appears.

The playground is a single-node `kind` cluster that runs one Prometheus server (version 3.5.5) and a small pod called `shuttle` that holds a query helper. Prometheus scrapes nothing. It starts with a fixed block of data that covers one hour, from `2026-01-01T00:00:00Z` to `2026-01-01T01:00:00Z`, with one sample every 15 seconds. Because the data never changes, every query gives the same answer every time.

The helper sends one query to the Prometheus HTTP API and prints the result. Every hands-on step in this module has this form:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

By default the helper evaluates the query at Unix time 1767229200, the time of the last sample. Add `--time 1767228300` to evaluate at another time. The helper prints one line per series in the form `name{label="value"} value`, with the labels in alphabetical order. When a result has no metric name, the line starts with `{`. A scalar prints as `scalar 5`, an empty result prints as `(empty result)` and a failed query prints `error <type>: <message>`.

These metrics matter in this module:

| Metric | Type | Labels | What it holds |
| --- | --- | --- | --- |
| `up` | gauge | `job`, `instance` | 1 when the last scrape worked, 0 when it failed |
| `http_requests_total` | counter | `job`, `instance`, `method`, `status` | Requests handled, for `bridge`, `shuttle` and their methods and status codes |
| `queue_depth` | gauge | `job`, `instance` | Items waiting in a queue |
| `disk_used_bytes`, `disk_total_bytes` | gauge | `job`, `instance`, `mountpoint` | Disk usage of the two `probe` instances |
| `temperature_celsius` | gauge | `job`, `instance`, `sensor` | Temperature of the two `probe` instances |
| `process_start_time_seconds` | gauge | `job`, `instance` | Start time of each process, in Unix seconds |
| `backup_last_success_timestamp_seconds` | gauge | `job`, `instance` | Unix time of the last good backup |

## The order of the parts

The first part applies the arithmetic operators to scalars and vectors and shows which labels the result keeps. The second part turns to the comparison operators, first as filters and then with the `bool` modifier. The third part explains operator precedence and associativity, builds the error ratio, and follows what happens when a division has a zero or no data on one side.

Start your playground now and keep it open next to you while you read.

<!-- astrona:playground -->
