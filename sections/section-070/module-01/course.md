---
draft: true
exam_objectives:
- Timestamp Metrics
---
# time, timestamp And Age Of An Event

Many questions about a system are questions about time. When did this process start? How long ago did the last backup succeed? Is the newest sample of this series recent or old? PromQL answers all of them with subtraction: take the time of the evaluation, take the time of the event, and compute the difference in seconds.

Two inputs make this possible. The function `time()` returns the time at which the query is evaluated. A metric whose value is itself a Unix timestamp, such as `process_start_time_seconds`, carries the time of an event. The function `timestamp()` is a third input: it returns the time at which a sample was stored. This module explains the three sources of time, shows how to turn them into an age, and shows how to compare that age with a threshold to find work that is overdue.

## Learning objectives

After this module you can:

- Explain what `time()` returns, and why it is the evaluation time and not the wall clock of the server.
- Explain what `timestamp(v)` returns and how it differs from a metric that stores a timestamp as its value.
- Compute the uptime of a process as `time() - process_start_time_seconds`.
- Compute the age of the last successful backup from `backup_last_success_timestamp_seconds`.
- Convert an age from seconds to minutes, hours or days and compare it with a threshold.
- Write an overdue-work expression that returns only the series that are over the threshold.

## Before you start

You need to know what a Prometheus metric, a label and an instant query are. You do not need any other Prometheus component.

The playground runs on a single-node `kind` cluster. It has a Prometheus server (version 3.5.5) with a fixed dataset that was loaded as a block of stored samples. Prometheus scrapes nothing and has no rules, so the data never changes. The dataset holds one hour of samples, one every 15 seconds, from Unix time 1767225600 (2026-01-01T00:00:00Z) to 1767229200 (01:00:00Z). The newest sample of every series is at 1767229200.

A pod named `shuttle` in the namespace `starfleet` holds a small query helper. Every command in this module has this form, where the text in quotes is the PromQL expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

The helper sends an instant query to Prometheus and prints one line per series: the metric name (if the result keeps it), the labels in braces, and the value. A scalar prints as `scalar 5`, and an empty result prints as `(empty result)`. Without an option the helper evaluates at 1767229200. With `--time 1767228900` it evaluates at that Unix time. With `--now` it lets the server use its own current time, and because the dataset is old, most queries then return an empty result.

The dataset has three groups of series that this module uses: `process_start_time_seconds` and `backup_last_success_timestamp_seconds` (their values are Unix timestamps), and `up` (the result of each scrape). Their `job` labels are `bridge`, `shuttle` and `probe`, and their `instance` labels name one process each. All numbers in the examples come from the dataset formulas, so your output must match them exactly where an output block is shown.

## The order of the parts

The first part explains the difference between `time()` and `timestamp()` and shows what each one returns for the same query. The second part uses a timestamp-valued metric to compute uptime and the age of a backup. The third part turns an age into an overdue-work expression: unit conversion, a threshold, and the shape of the result. A graded lab follows the third part. The module ends with a summary.

Start your playground now and keep it running while you read:

<!-- astrona:playground -->
