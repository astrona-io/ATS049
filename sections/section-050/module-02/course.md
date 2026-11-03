---
draft: true
exam_objectives:
- Binary operators
---

# Vector Matching And Set Operators

Two numbers are easy to combine. Two vectors are harder, because each vector holds many series and the engine must decide which series on the left belongs with which series on the right. A division of errors by requests, a join of a metric with its version, or a test such as "queue depth, but only for targets that are down" all depend on that decision. Prometheus calls it vector matching, and it is a frequent source of results that are empty, wrong or rejected with an error.

This module covers how series are paired by default, how to change the pairing with `on` and `ignoring`, how to pair many series with one using `group_left` and `group_right`, and how the set operators `and`, `or` and `unless` combine whole vectors by their labels.

## Learning objectives

After this module you can:

- Explain why two series match only when their labels are identical, and why the metric name is not part of the comparison.
- Use `on(...)` and `ignoring(...)` to choose the labels used for matching, and say which labels the result keeps.
- Explain the error that Prometheus returns when one side of a match has more than one series for the same labels.
- Use `group_left` and `group_right` to match many series with one, and copy labels such as `version` and `team` from an info metric.
- Say which side of a many-to-one match is the many side and which labels the result carries.
- Use `and`, `or` and `unless` to keep, add or remove series by their labels, and explain that they ignore the values on the right.

## Before you start

You need to know what a label, an instant vector and a selector are, and how arithmetic and comparison operators work between a vector and a number. The module explains the rest.

The playground is a single-node `kind` cluster that runs one Prometheus server (version 3.5.5) and a pod called `shuttle` that holds a query helper. Prometheus scrapes nothing. It starts with a fixed block of data from `2026-01-01T00:00:00Z` to `2026-01-01T01:00:00Z`, with one sample every 15 seconds, so every query gives the same answer every time.

Every hands-on step has this form:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

The helper evaluates the query at Unix time 1767229200, the time of the last sample, unless you add `--time 1767228300` or another time. It prints one line per series as `name{label="value"} value`, with the labels in alphabetical order. A result without a metric name starts with `{`. An empty result prints `(empty result)`, and a failed query prints `error <type>: <message>`.

These metrics matter in this module:

| Metric | Labels | What it holds |
| --- | --- | --- |
| `up` | `job`, `instance` | 1 when the last scrape worked, 0 when it failed. `shuttle-0` is 0 from 1767228000 to 1767228585. |
| `http_requests_total` | `job`, `instance`, `method`, `status` | Request counters for `bridge-0`, `bridge-1` and `shuttle-0`, with the status 200 and 500. |
| `queue_depth` | `job`, `instance` | Items waiting in a queue, one series per instance. |
| `build_info` | `job`, `instance`, `version` | Always 1. The software version of each instance. |
| `team_info` | `job`, `instance`, `team` | Always 1. The team that owns each instance. |
| `error_budget_ratio` | `job` | The allowed error ratio per job: 0.02 for `bridge` and 0.1 for `shuttle`. |

## The order of the parts

The first part explains one-to-one matching, the default, and the `on` and `ignoring` modifiers. The second part handles many-to-one and one-to-many matching with `group_left` and `group_right`, including how to copy labels from the `build_info` and `team_info` metrics. The third part turns to the set operators, which combine vectors by label sets and not by values.

Start your playground now and keep it open next to you while you read.

<!-- astrona:playground -->
