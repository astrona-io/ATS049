---
draft: true
exam_objectives:
- Aggregating over time
---
# The over_time Functions

A metric in Prometheus is a series of samples, and a dashboard or an alert rarely cares about one sample. It cares about a period: the highest queue depth in the last ten minutes, the lowest value of `up` in the last five minutes, whether a series sent any sample at all in the last hour. PromQL (the Prometheus Query Language) answers these questions with the `*_over_time` functions. Each one reads the samples inside a time window of one series and returns a single value for that series.

Keep one sentence in mind for this module: **an over_time function takes a range vector, reduces the samples of each series in the window to one value, and returns an instant vector with one result per series.** You will run every function against a fixed dataset, predict the answer from the dataset formulas, and compare it with the output.

The module has three parts. **Aggregating A Gauge Over A Window** introduces the range vector and the five basic functions `avg_over_time`, `min_over_time`, `max_over_time`, `sum_over_time` and `count_over_time`, and shows what each one returns for every series. **Quantiles, Spread, Last Value And Presence** covers `quantile_over_time`, `stddev_over_time`, `last_over_time`, `present_over_time` and `absent_over_time`, including what happens to a series that stopped sending samples. **Choosing The Window And Avoiding Misleading Averages** explains how the size of the window relates to the scrape interval, and why an average of a counter or of a ratio gives a number that means nothing.

## Learning objectives

After this module you can:

- Explain what a range vector is and which samples a range such as `[5m]` selects.
- Use `avg_over_time`, `min_over_time`, `max_over_time`, `sum_over_time` and `count_over_time` and say what each returns per series.
- Use `quantile_over_time` and `stddev_over_time` to describe how a gauge is spread over a window.
- Use `last_over_time`, `present_over_time` and `absent_over_time` to find the newest value of a series and to detect a series that has no samples.
- Choose a window that holds enough samples for the scrape interval and long enough to cover the pattern you look for.
- Explain why `avg_over_time` of a counter and an average of ratios mislead, and name the correct alternative.

## Before you start

You need to know what a metric, a label and an instant vector selector are, for example `up{job="bridge"}`. You do not need to know any function yet.

The playground is a single-node `kind` cluster. It runs one Prometheus server version 3.5.5 in the namespace `starfleet`. Prometheus does not scrape anything. Instead, it starts with one hour of stored samples that were generated from fixed formulas: one sample every 15 seconds, from 2026-01-01T00:00:00Z (Unix time 1767225600) to 01:00:00Z (Unix time 1767229200). A pod called `shuttle` runs a small helper that sends a query to Prometheus and prints the result.

Every command in this module has this form:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

The helper evaluates the expression at Unix time 1767229200, the time of the newest sample, unless you add `--time <unix seconds>`. It prints one line per series, sorted, as `name{label="value", ...} value`. When a function drops the metric name, it prints only `{label="value", ...}`. A scalar prints as `scalar 5`, and a query with no result prints `(empty result)`. An error prints `error <type>: <message>`. A range vector prints the series name and then one indented line `<unix time> <value>` for every sample.

The series in this module are the gauge `queue_depth` with the labels `job` and `instance` (three series: `bridge-0:8080`, `bridge-1:8080` and `shuttle-0:8080`), the gauge `temperature_celsius` of the two `probe` instances, the `up` metric, and the counter `http_requests_total`. A **gauge** is a metric whose value can go up and down, such as a queue length or a temperature. The series `probe-1:9100` stops sending samples at Unix time 1767228600, which matters in the second part. Every command that needs another evaluation time says so.

Launch your playground now, and keep it running while you read the parts:

<!-- astrona:playground -->
