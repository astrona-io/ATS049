---
draft: true
exam_objectives:
- Timestamp Metrics
---
# Summary

A silent query is not a healthy query. Prometheus reports problems in two different ways: a value that is bad, and a series that is not there. Alerts and dashboards must watch for both, because the first needs a comparison and the second needs a test for absence.

## What you learned

Prometheus writes the metric `up` for every scrape target: 1 when the scrape worked and 0 when it failed. A target with `up` equal to 0 is known and failing. A target whose `up` series does not exist is not known, or no longer known. The expression `up == 0` finds the first case and cannot see the second one. A filter such as `up == 0` returns an empty result when nothing is down, and `count()` of an empty result is empty and not 0, so an alert on that count needs `or vector(0)` when a number is required.

An instant query returns the newest sample of a series within the lookback window, 5 minutes by default. The window is open at its left edge and closed at its right edge: a sample exactly 5 minutes old is not returned. After the window passes, the series has no value at that time. The function `absent(v)` returns a one-element vector with the value 1 when `v` has no element, and an empty vector otherwise. The labels of that element come from the equality matchers of the selector, each on its own label name. Regular expression matchers, inequality matchers and the metric name add no label, and an aggregation inside `absent()` leaves an empty label set. The function `absent_over_time(v[range])` does the same test over a range instead of the lookback window, and the same left-open rule decides which samples count.

The function `changes(v[range])` counts how often the value of each series differs from the sample before it inside the range. On a start time metric, a count above zero means that the process restarted in that range. Because the range is left-open, a change that happens exactly at the first sample of the range is not counted, so the range must reach back beyond the restart. The expression `time() - timestamp(v)` is the age of the newest sample, and a value above the scrape interval means that the series is late while it still lies inside the lookback window. The pair `v offset 10m unless v` returns the series that existed 10 minutes ago and do not exist now. A failed scrape leaves a sample with the value 0, and a gap leaves no sample, so `count_over_time()` against the expected number of samples exposes a gap.

The key facts to remember are these:

- `up == 0` detects a failing target. `absent()` detects a missing one.
- The labels of an `absent()` result come only from equality matchers.
- A range selector and the lookback window are left-open.
- `changes()` on a start time above 0 means a restart in the range.
- A stale series still answers `timestamp()`, until the lookback window ends.

<!-- astrona:playground:destroy -->
