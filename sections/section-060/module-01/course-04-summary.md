---
draft: true
exam_objectives:
- Histograms
---

# Summary

A classic histogram is a group of counters. For each upper bound the application keeps a cumulative counter in the series `_bucket` with the label `le`, and it also keeps a `_sum` series and a `_count` series. Each bucket counts every observation at or below its bound, so the `le="+Inf"` bucket equals the count. The number of observations in one range is the difference of two neighbouring buckets. The bounds are chosen by the application, and more bounds and more labels mean more series.

Because the counters grow for the whole life of a process, a quantile for a time window starts with `rate` over the buckets. The function `histogram_quantile` then finds the bucket that holds the observation at the requested rank and interpolates linearly inside it. This assumes an even spread of observations in the bucket, so the result is an estimate that can be wrong by up to the width of that bucket. When the rank lies in the `+Inf` bucket, the function returns the upper bound of the highest finite bucket.

The label `le` is what makes the function work. An aggregation must keep it, as in `sum by (le)` or `sum by (instance, le)`, because a series without `le` is ignored and the result is empty without an error. The other labels in the `by` clause decide what each result describes.

For a quantile of a whole service, add the bucket rates of all instances first and take the quantile once. A quantile of quantiles, through `avg` or `max`, ignores how many requests each instance served and gives a wrong value. The sum is valid only when all instances use the same bounds.

When a process restarts, its counters drop to 0. Raw bucket values then move backwards, and a quantile from raw buckets weights each instance by its lifetime. The function `rate` detects the drop, counts from 0 and keeps the ratios between the buckets, so the quantile stays correct across a reset.

Key facts to remember:

- Bucket values are cumulative, and `le="+Inf"` equals `_count`.
- The order is `rate`, then `sum by (le)`, then `histogram_quantile`.
- Dropping `le` gives an empty result, not an error.
- The result is an interpolation within one bucket and never more exact than the bucket width.
- Never average or take the maximum of quantiles from several instances.

<!-- astrona:playground:destroy -->
