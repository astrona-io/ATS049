---
draft: true
exam_objectives:
- Aggregating over time
---
# Subqueries And Nested Time Aggregation

The `*_over_time` functions need a range vector, and a range selector such as `[5m]` works only directly on a metric selector. Many useful questions are about an expression: the highest total request rate of a job in the last ten minutes, or the lowest number of healthy instances per job in the last hour. The total request rate is the result of `rate()` and `sum`, so it has no range selector to attach a window to. A **subquery** solves this. It runs an instant vector expression many times over a period and returns the results as a range vector, which an over_time function can then reduce.

Keep one sentence in mind for this module: **a subquery `expr[range:step]` evaluates `expr` at every step time inside the range, and the outer function reduces those values per series.** You will run subqueries against a fixed dataset, predict the answer from the dataset formulas, and look at the cost that a subquery adds.

The module has three parts. **Subquery Syntax And Evaluation Times** explains `expr[range:step]`, the default step and the exact times at which Prometheus evaluates the inner expression. **Nesting Time Aggregation With Aggregates And Rates** combines `max_over_time`, `sum by` and `rate()` in one expression and shows that the order of the operations changes the result. **Cost, Recording Rules And Nesting Pitfalls** counts the evaluations that a subquery makes, shows when a recording rule is the better tool, and lists the mistakes that give wrong numbers.

## Learning objectives

After this module you can:

- Write a subquery with an explicit step and with the default step, and say what the default step is.
- State at which times Prometheus evaluates the inner expression of a subquery and which of them belong to the range.
- Combine an over_time function with `sum by` and `rate()` to find the peak, the lowest value or the average of a computed value over time.
- Explain why the maximum of a sum and the sum of maximums are different results.
- Count the evaluations that a subquery makes, and explain when a recording rule is cheaper.
- Avoid the common mistakes: aggregating a counter before `rate()`, a step that is longer than the inner range, and a range that holds one point.

## Before you start

You need to know what a range vector is, how a range selector such as `[5m]` selects samples (left-open and right-closed), and what the functions `max_over_time`, `min_over_time`, `avg_over_time` and `count_over_time` return. You also need `rate()` and `sum by (label)`: `rate(x[1m])` returns the per-second average increase of a counter over the last minute, and `sum by (job)` adds up series that share the same `job` label.

The playground is a single-node `kind` cluster. It runs one Prometheus server version 3.5.5 in the namespace `starfleet`. Prometheus does not scrape anything. Instead, it starts with one hour of stored samples that were generated from fixed formulas: one sample every 15 seconds, from 2026-01-01T00:00:00Z (Unix time 1767225600) to 01:00:00Z (Unix time 1767229200). A pod called `shuttle` runs a small helper that sends a query to Prometheus and prints the result. The global evaluation interval of this Prometheus server is 15 seconds.

Every command in this module has this form:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

The helper evaluates the expression at Unix time 1767229200, the time of the newest sample, unless you add `--time <unix seconds>`. It prints one line per series, sorted, as `name{label="value", ...} value`. When a function drops the metric name, it prints only `{label="value", ...}`. A scalar prints as `scalar 5`, and a query with no result prints `(empty result)`. An error prints `error <type>: <message>`. A range vector prints the series name and then one indented line `<unix time> <value>` for every point.

The series in this module are the gauge `queue_depth` (`bridge-0:8080`, `bridge-1:8080` and `shuttle-0:8080`), the counter `http_requests_total` with the labels `job`, `instance`, `method` and `status`, and the `up` metric. The instance `bridge-1:8080` restarts at Unix time 1767227400, and its counters start again from 0. The series `probe-1:9100` of `up` has no sample after Unix time 1767228600.

Launch your playground now, and keep it running while you read the parts:

<!-- astrona:playground -->
