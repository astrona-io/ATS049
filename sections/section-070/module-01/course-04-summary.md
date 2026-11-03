---
draft: true
exam_objectives:
- Timestamp Metrics
---
# Summary

PromQL has no clock function that returns the current time of the server. It has `time()`, which returns the time at which the query is evaluated, as seconds since 1970-01-01 UTC. For an instant query without a `time` parameter this is the current time of the server. For a query evaluated at a chosen time, and for every step of a range query, it is that chosen time. Because of this, an age computed with `time()` is correct for any moment you evaluate, including a moment in the past.

## What you learned

A sample has two different times. The timestamp of a sample is the moment at which Prometheus stored it, and the function `timestamp(v)` returns it as a number of seconds. The value of a sample can also be a time, as in a gauge such as `process_start_time_seconds` or `backup_last_success_timestamp_seconds`, where the process that exposes the metric writes a Unix time into the value. The first answers the question "how fresh is this series". The second answers the question "when did this event happen".

The age of an event is `time()` minus the timestamp-valued metric. The result is a number of seconds, and the output labels are the labels of the metric without its name. The uptime of a process is the age of its start time. The age of the last backup is the age of its success time. When a process restarts, its start time moves forward and its uptime returns to a small number. When a backup job stops, its success time stays the same and its age grows by one second for every second of evaluation time.

Seconds are the unit of all these results. To read an age in minutes, hours or days, divide by 60, 3600 or 86400. A threshold is a number in the same unit as the result, and a comparison operator without the `bool` modifier keeps only the series that satisfy it and drops the others. A result with a value is a series that is overdue. An empty result means that no series is overdue, but it can also mean that no series exists, which is a separate failure.

The key facts to remember are these:

- `time()` is the evaluation time, not the wall clock when `--time` or a range query sets the time.
- `timestamp(v)` is the time of the stored sample, and `v` itself is a plain selector.
- Age is `time() - metric`, and uptime is the age of a start time.
- Division binds tighter than subtraction, so write `(time() - metric) / 60` with parentheses.
- A comparison filters by default; with `bool` it returns 1 or 0 for every series.
- A series that has no sample inside the lookback window produces no age and no alert.

<!-- astrona:playground:destroy -->
