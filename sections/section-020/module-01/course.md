---
draft: true
exam_objectives:
- Rates and Derivatives
---
# Counters, rate And increase

A counter is a metric that only goes up while a process runs. It counts requests, errors, bytes or seconds of CPU time. The raw value of a counter is almost never useful on its own: a number such as 136000 tells you how many requests happened since the process started, not how busy the service is right now. PromQL (the Prometheus Query Language) answers the useful question with functions that turn a counter into a speed: `rate()`, `increase()` and `irate()`. These functions also repair the one thing that breaks a counter, a restart of the process that owns it.

Keep one sentence in mind for this chapter: **a counter function reads the samples inside a range, fixes counter resets, and stretches the result to the full range.** You will run each function against a fixed dataset, predict the answer from the dataset formulas before you run it, and then compare.

The chapter has three parts. The first part explains `rate()`, the range selector and how the size of the range relates to the scrape interval. The second part compares `rate()`, `increase()` and `irate()` and says what each one returns. The third part follows a restart of one process through the functions, and explains why you aggregate after you take the rate and never before.

## Learning objectives

After this chapter you can:

- Explain what a counter is and why `rate()` is the right function for it.
- Choose a range for `rate()` that holds enough samples for the scrape interval.
- Predict the value of `rate()` and `increase()` for a counter that grows by a constant amount.
- Choose between `rate()`, `increase()` and `irate()` for a graph, an alert and a quick look at a spike.
- Explain how Prometheus detects a counter reset and what it adds back.
- Write `sum by (...)` and `sum without (...)` over `rate()` and explain why `rate(sum(...))` is wrong.

## Before you start

You need to know what a metric, a label and an instant vector selector are, for example `up{job="bridge"}`, and you need to be able to read a range selector such as `[5m]`.

The playground is a single-node `kind` cluster. It runs one Prometheus server version 3.5.5 in the namespace `starfleet`. Prometheus does not scrape anything. Instead, it starts with one hour of stored samples that were generated from fixed formulas: one sample every 15 seconds, from 2026-01-01T00:00:00Z (Unix time 1767225600) to 01:00:00Z (Unix time 1767229200). A pod called `shuttle` runs a small helper that sends a query to Prometheus and prints the result.

Every command in this chapter has this form:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

The helper evaluates the expression at Unix time 1767229200, the time of the newest sample, unless you add `--time <unix seconds>`. It prints one line per series, sorted, as `name{label="value", ...} value`. When a function drops the metric name, it prints only `{label="value", ...}`. A scalar prints as `scalar 5`, and a query with no result prints `(empty result)`. An error prints `error <type>: <message>`.

The series in this chapter are the counter `http_requests_total` with the labels `job`, `instance`, `method` and `status`, and the `up` metric. There are ten `http_requests_total` series, from three instances: `bridge-0:8080` and `bridge-1:8080` (job `bridge`) and `shuttle-0:8080` (job `shuttle`). Every counter grows by the same amount in every 15 second step. The instance `bridge-1:8080` restarts at Unix time 1767227400, and its counters start again from 0.

Launch your playground now, and keep it running while you read the parts:

<!-- astrona:playground -->
