---
draft: true
exam_objectives:
- Timestamp Metrics
---
# Freshness, Absence And Gaps

A query that returns a number is easy to read. A query that returns nothing is not: it can mean that everything is fine, or that the thing you wanted to watch has vanished. Alerts that watch for a bad value stay silent when the series that holds the value is gone. This module teaches how to detect that a series is down, missing, stale or restarted, using `up`, `absent()`, `absent_over_time()`, `changes()` and `timestamp()`.

Each of these tools answers a different question. A series with the value 0 in `up` is a target that is known and failing. A series that does not exist is a target that nobody reports. A series that exists but has an old sample is a target that stopped reporting a moment ago. A series whose start time moved is a process that restarted. You need all four tests, because each failure leaves a different trace in the data.

## Learning objectives

After this module you can:

- Explain what `up` is, who writes it, and the difference between `up == 0` and a missing `up` series.
- Use `absent()` and `absent_over_time()` and predict the labels of the series they return.
- Explain why an instant query stops returning a series about 5 minutes after its last sample, and how the left-open window decides the exact moment.
- Detect restarts with `changes()` on a start time metric.
- Find stale series with `time() - timestamp(v)` and series that vanished with `offset` and `unless`.
- Tell a gap in the samples from a failed scrape.

## Before you start

You need to know what a metric, a label and an instant query are, and that `time()` returns the evaluation time.

The playground runs on a single-node `kind` cluster with a Prometheus server (version 3.5.5) that holds a fixed dataset, loaded as a block of stored samples. Prometheus scrapes nothing and has no rules, so the data never changes. The dataset has one hour of samples, one every 15 seconds, from Unix time 1767225600 to 1767229200. The newest sample of every series is at 1767229200.

Three events in the dataset are used in this module. The instance `shuttle-0` reports `up` with the value 0 between 1767228000 and 1767228585. The instance `probe-1` has no samples after 1767228600, so its series ends. The instance `bridge-1` restarts at 1767227400, and its `process_start_time_seconds` jumps to that time.

A pod named `shuttle` in the namespace `starfleet` holds a small query helper. Every command in this module has this form, where the text in quotes is the PromQL expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

The helper sends an instant query to Prometheus and prints one line per series: the metric name (if the result keeps it), the labels in braces, and the value. A scalar prints as `scalar 5`, and an empty result prints as `(empty result)`. Without an option the helper evaluates at 1767229200, and `--time 1767228300` evaluates at that Unix time. All numbers in the examples come from the dataset formulas.

## The order of the parts

The first part explains `up` and what a missing series means. The second part covers `absent()` and `absent_over_time()` and the labels they return. The third part covers restarts, stale series, vanished series and gaps. A graded lab follows the third part. The module ends with a summary.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
