---
draft: true
exam_objectives:
- Rates and Derivatives
---
# Gauges: delta, deriv And predict_linear

A gauge is a metric that can go up and down: the depth of a queue, the temperature of a processor, the bytes used on a disk. A gauge is not a counter, so the counter functions are the wrong tool for it. PromQL (the Prometheus Query Language) has its own functions for gauges. They answer questions such as how much a value changed, how fast it is changing, and when it will reach a limit. Two more functions count events inside the samples: how often a value changed, and how often a counter was reset.

Keep one sentence in mind for this chapter: **a gauge function fits a line or a difference to the samples in the range and does not know about counter resets.** You will predict each answer from the dataset formulas, run the query, and compare.

The chapter has three parts. The first part explains `delta()` and `idelta()` and when a metric is a gauge and not a counter. The second part explains `deriv()` and `predict_linear()` with linear regression, using a filling disk and a heating processor. The third part explains `changes()` and `resets()`, and ends with a method to choose the right function for a question.

## Learning objectives

After this chapter you can:

- Decide whether a metric is a counter or a gauge from its behaviour, and name the function family for each.
- Use `delta()` and `idelta()` to measure the change of a gauge over a range or between the last two samples.
- Explain why `rate()` gives a wrong result on a gauge that goes down.
- Use `deriv()` to measure the speed of change of a gauge in units per second.
- Use `predict_linear()` to predict a value, and to compute the time until a disk is full.
- Describe how simple linear regression picks the line, and what the range does to the answer.
- Use `changes()` and `resets()` to count value changes and counter resets.
- Choose between all the counter and gauge functions for a given question.

## Before you start

You need to know what a gauge and a counter are, and how to read a range selector such as `[5m]`. The range is left-open and right-closed: it holds the samples with a timestamp greater than `t - 5m` and up to `t`.

The playground is a single-node `kind` cluster. It runs one Prometheus server version 3.5.5 in the namespace `starfleet`. Prometheus does not scrape anything. Instead, it starts with one hour of stored samples that were generated from fixed formulas: one sample every 15 seconds, from 2026-01-01T00:00:00Z (Unix time 1767225600) to 01:00:00Z (Unix time 1767229200). A pod called `shuttle` runs a small helper that sends a query to Prometheus and prints the result.

Every command in this chapter has this form:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

The helper evaluates the expression at Unix time 1767229200, the time of the newest sample, unless you add `--time <unix seconds>`. It prints one line per series, sorted, as `name{label="value", ...} value`. When a function drops the metric name, it prints only `{label="value", ...}`. A scalar prints as `scalar 5`, and a query with no result prints `(empty result)`. An error prints `error <type>: <message>`.

The series in this chapter are the gauges `queue_depth`, `disk_used_bytes`, `disk_total_bytes` and `temperature_celsius`, and the counter `http_requests_total` and the gauge `process_start_time_seconds`. The queue of `bridge-0:8080` is a triangle wave between 10 and 30 with a period of 10 minutes. The queue of `bridge-1:8080` is 5 and then 25 from Unix time 1767227400. The queue of `shuttle-0:8080` is 0 until Unix time 1767227100 and then grows by 2 in every 15 second step. The disks and the temperatures belong to the instances `probe-0:9100` and `probe-1:9100`. The disk of `probe-0:9100` fills by 15,000,000 bytes per step and the disk of `probe-1:9100` by 7,500,000 bytes per step, both from 40 GB, and both disks are 100 GB. The series of `probe-1:9100` stop at Unix time 1767228600.

Launch your playground now, and keep it running while you read the parts:

<!-- astrona:playground -->
