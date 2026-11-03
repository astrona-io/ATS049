---
draft: true
exam_objectives:
- Aggregating over dimensions
---
# Aggregation Operators With by And without

Prometheus stores one time series for every combination of metric name and label values. A single metric such as `http_requests_total` can have ten series, and a real system can have thousands. Nobody reads thousands of lines. An aggregation operator in PromQL (the Prometheus query language) takes many series and combines them into fewer series, for example one total per job. The two keywords `by` and `without` decide which labels survive the combination.

This module teaches the aggregation operators `sum`, `min`, `max`, `avg`, `count` and `group`, the rule that decides which labels the result keeps, and the habit of aggregating a rate instead of a raw counter. It ends with counting series, which is how you measure how many targets and how many series a system has.

The module has three parts. The first part runs every basic operator, compares `by` with `without`, and shows which labels disappear, including the metric name. The second part builds the most common production query: the sum of a rate, grouped by instance and by mode, on the CPU counters. The third part uses `count` and `count by` to measure cardinality (the number of series) and to read the `up` metric.

## Learning objectives

After this module you can:

- Name what `sum`, `min`, `max`, `avg`, `count` and `group` return for one group of series.
- Predict the label set of a result from a `by` clause or a `without` clause.
- Explain why aggregation removes the metric name and every label that is not kept.
- Write `sum by (...) (rate(...))` and explain why the rate comes before the sum.
- Count targets and series with `count`, `count by` and a count of a count.
- Read the `up` metric to find targets that are down and targets that have vanished.

## Before you start

You need to know what a metric, a label and a time series are, and what an instant vector is: a set of series with one sample each, taken at one evaluation time. You also need the functions `rate` and the range selector `[5m]`. The first use of each is explained again where it appears.

Your playground is a single-node `kind` cluster with a Prometheus server (version 3.5.5) and a pod called `shuttle` in the namespace `starfleet`. Prometheus does not scrape anything. It starts with a fixed dataset that was written into it before the start: one hour of samples, one sample every 15 seconds, from Unix time `1767225600` to `1767229200`. The dataset describes five targets: `bridge-0` and `bridge-1` (job `bridge`), `shuttle-0` (job `shuttle`) and `probe-0` and `probe-1` (job `probe`). The metrics are `up`, `http_requests_total`, `queue_depth`, `node_cpu_seconds_total`, `disk_used_bytes`, `http_request_duration_seconds` and a few others.

Every command in this module has the same form:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

The command runs a small helper script, `pq.py`, inside the `shuttle` pod. The script sends your expression to Prometheus and prints one line per series in the form `name{label="value"} value`. It evaluates at Unix time `1767229200`, the last sample, unless you add `--time <unix seconds>`. When the metric name is not part of the result, the line starts with `{`. A scalar prints as `scalar 5`, and an empty result prints `(empty result)`. The helper sorts its lines as text, so the order of the lines can differ from the order in the Prometheus web interface.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
