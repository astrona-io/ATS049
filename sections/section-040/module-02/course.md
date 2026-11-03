---
draft: true
exam_objectives:
- Aggregating over dimensions
---
# topk, bottomk, quantile, count_values And Statistics

The basic aggregations give one number for a group. Many operational questions need something else: which instances are the busiest, what is the typical value, how much do the values differ, and how many series share one value. PromQL answers these with `topk`, `bottomk`, `quantile`, `stddev`, `stdvar` and `count_values`. This module teaches what each of them returns, which labels the result keeps, and how to avoid the most common wrong answer: an average that hides a failing instance.

The module has three parts. The first part ranks series with `topk` and `bottomk`, including per-group ranking with `by` and what happens with ties. The second part describes a set of values with `quantile`, `stddev` and `stdvar`, and counts how often a value occurs with `count_values`. The third part compares correct and incorrect averaging, in particular the average of averages, and shows how an aggregate can hide one failing instance.

## Learning objectives

After this module you can:

- Select the highest or lowest series with `topk` and `bottomk`, and explain why the result keeps all original labels.
- Rank series inside each group with `by` and `without`, and predict what happens when values are equal.
- Compute a quantile, a standard deviation and a variance across series, and say how a quantile across series differs from a quantile of histogram buckets.
- Use `count_values` to count how many series have each value.
- Explain why the average of per-instance averages is wrong, and write the weighted form.
- Choose an aggregation that shows a failing instance instead of hiding it.

## Before you start

You need the basic aggregation operators and the `by` and `without` clauses: an aggregation groups series by their labels and returns one series for each group, with the metric name removed. You also need the function `rate` and the range selector `[5m]`. Each is explained again where it is used.

Your playground is a single-node `kind` cluster with a Prometheus server (version 3.5.5) and a pod called `shuttle` in the namespace `starfleet`. Prometheus does not scrape anything. It starts with a fixed dataset that was written into it before the start: one hour of samples, one sample every 15 seconds, from Unix time `1767225600` to `1767229200`. The dataset describes five targets: `bridge-0` and `bridge-1` (job `bridge`), `shuttle-0` (job `shuttle`) and `probe-0` and `probe-1` (job `probe`). The metrics used here are `queue_depth`, `up`, `http_requests_total`, `http_request_duration_seconds` and `team_info`.

Every command in this module has the same form:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'queue_depth'
```

The command runs a small helper script, `pq.py`, inside the `shuttle` pod. The script sends your expression to Prometheus and prints one line per series in the form `name{label="value"} value`. It evaluates at Unix time `1767229200`, the last sample, unless you add `--time <unix seconds>`. When the metric name is not part of the result, the line starts with `{`. The helper sorts its lines as text, so the order of the lines is not the order of the values. The dataset has a few fixed facts that the parts use. The target `probe-1` has no samples after `1767228600`, so it is missing at the default time. The target `bridge-1` restarts at `1767227400`, and all its counters return to zero there. The target `shuttle-0` has `up` equal to `0` from `1767228000` until `1767228585`.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
