---
draft: true
exam_objectives:
- Aggregating over time
---
# Summary

A range selector such as `[5m]` turns an instant vector selector into a range vector: for every series, the list of samples with a timestamp greater than the evaluation time minus the range, up to and including the evaluation time. An over_time function reduces that list to one value per series and returns an instant vector. Series with no sample in the window do not appear in the result. Every sample in the window has the same weight, whatever the time between the samples.

`min_over_time`, `max_over_time`, `sum_over_time`, `count_over_time` and `avg_over_time` describe a gauge over a window. They drop the metric name and keep every other label. `quantile_over_time` takes a quantile between 0 and 1 as its first argument and interpolates between the two nearest sorted samples. `stddev_over_time` returns the population standard deviation, which is 0 for a constant gauge. `last_over_time` returns the newest sample in the window and is the one function that keeps the metric name. `present_over_time` returns 1 for each series that has at least one sample. `absent_over_time` returns one series with value 1 when the selector has no samples at all, and its labels come from the equality matchers of the selector.

The window decides what the answer can see. A window shorter than the scrape interval can hold no sample, and the series then disappears from the result. A window shorter than the cycle of a gauge misses its peaks or its low points. A window that ends at a series' last sample can still lose that sample when the sample lies exactly on the left boundary of the range.

An average hides the thing that matters for two kinds of metric. The average of a counter is a mean of running totals, so it depends on when the process started and breaks at a restart. The average of a ratio gives a quiet period the same weight as a busy one. For a counter, take `rate()` or `increase()`. For a ratio, divide the sums over the window instead of averaging the ratios.

Key facts:

- A range is left-open and right-closed: a sample exactly at the evaluation time minus the range is not selected.
- The result of an over_time function has one series for each input series that has samples in the window.
- `sum_over_time(up[5m])` divided by `count_over_time(up[5m])` is the share of samples in which a target was up.
- A window of four times the scrape interval is the usual minimum for functions that need several samples.

<!-- astrona:playground:destroy -->
