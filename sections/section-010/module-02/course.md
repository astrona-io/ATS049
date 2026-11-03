---
draft: true
exam_objectives:
- Selecting Data
---
# Evaluation Time: Lookback, Staleness, Offset And @

A PromQL expression always has an evaluation time. The same selector returns different series and different values at different times, and sometimes nothing at all. Many wrong dashboards and wrong alert expressions come from misreading time: a series that seems to be missing, a value that is a few minutes old, or a graph that hides a short failure.

This topic explains how Prometheus turns a point in time into a sample. You learn the lookback delta, which decides how old a sample may be, and staleness, which decides when a series disappears from results. You then learn the `offset` and `@` modifiers, which move one selector to another time, and how a range query repeats the evaluation at every step.

The topic has three parts. The first part covers the lookback delta and staleness, and explains why a query for the current time returns nothing in the playground and why one target vanishes from the results of the last minutes of the data. The second part covers `offset`, negative offsets and the `@` modifier with `start()` and `end()`. The third part covers range queries: the step, the window of a range selector, and how an evaluation at a given time works.

## Learning objectives

After this topic you can:

- State how an instant vector selector chooses a sample: the newest sample in the lookback window that ends at the evaluation time.
- Explain staleness, and explain why a series with no recent samples is absent from a result without any error.
- Move a selector in time with `offset`, including a negative offset, and pin it to a fixed time with `@`, `@ start()` and `@ end()`.
- Predict the result when `@` and `offset` are combined on one selector.
- Explain how a range query evaluates an expression at each step, and the difference between the step and the window of a range selector.
- Choose an evaluation time with `--time`, and explain why `--now` returns nothing in this data.

## Before you start

You need to know what a selector is, what a series is and what the four label matchers do. The commands use only selectors, `sum`, `count` and simple arithmetic, so no function knowledge is needed.

Your playground is the same environment as in the selector topic: a single-node `kind` cluster with the namespace `starfleet`, a Prometheus server (version 3.5.5) that scrapes nothing and starts from a generated data block, and a `shuttle` pod with the query helper `/tools/pq.py`. The data covers one hour at one sample every 15 seconds, from Unix time 1767225600 (`2026-01-01T00:00:00Z`) to 1767229200 (`2026-01-01T01:00:00Z`). There are 68 series. The helper evaluates a query at 1767229200 unless you pass another time.

Three facts of the data matter for this topic:

- The target `probe-1:9100` stops reporting after Unix time 1767228600 (`00:50:00Z`). Its series have no sample after that.
- The target `shuttle-0:8080` reports `up` as 0 from 1767228000 to 1767228585, then 1 again.
- The target `bridge-1:8080` restarts at 1767227400 (`00:30:00Z`): its counters drop to 0 and its `queue_depth` jumps from 5 to 25.

Every command has the same form. It runs the helper inside the `shuttle` pod and passes one expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

The helper prints one line per series: the metric name, the labels in alphabetical order inside braces, and the value. A scalar prints as `scalar 5`, an empty result prints `(empty result)`, and an error prints `error` with the error type and message. Three options set the time. `--time UNIX` evaluates an instant query at that Unix time. `--now` sends no time, so the server uses its own clock. `--range START END STEP` runs a range query and prints each series followed by one indented `timestamp value` line per step.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
