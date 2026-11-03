---
draft: true
exam_objectives:
- Histograms
---

# Summary

The `_sum` and `_count` series of a histogram give the mean duration. The mean of a window is the rate of the sum divided by the rate of the count, and both rates must use the same window. The unit is seconds per request. A mean for the whole service divides the summed rates of all instances. An average of the instance means is wrong, because it gives every instance the same weight even when one serves more requests.

A bucket gives the number of observations at or under its bound, so the share of fast requests is a bucket rate divided by the rate of the count. The two sides have different labels, because the bucket has `le`. The modifier `ignoring(le)` or an aggregation with `sum` makes them match, and without it the result is empty and no error appears. The share above a threshold is the total minus the bucket. A threshold works only when a bucket has exactly that bound, because PromQL cannot create buckets. An Apdex score adds two cumulative buckets and divides by two and by the count.

A summary calculates its quantiles in the application. It is exact enough for one process and cheap for the server, but the quantiles and the window are fixed in the code, and the quantile values of several instances cannot be combined. A classic histogram only counts. The server calculates the quantile at query time, so quantile, window and aggregation are free choices, but the accuracy is limited by the width of the bucket and the application must define the bounds in advance.

A native histogram stores the count, the sum and exponential buckets in one sample. It has no `le` label and no `_bucket` series. The schema sets the resolution, a zero bucket takes values near zero, and histograms from different instances can always be merged. Queries become shorter: `sum` instead of `sum by (le)` before `histogram_quantile`, `histogram_avg` for the mean and `histogram_fraction` for a share between two values. Native histograms need protobuf exposition and, depending on the version, a flag or a scrape setting.

Key facts to remember:

- Mean: `rate(_sum) / rate(_count)`; for the service, sum both sides before dividing.
- Share under a bound: bucket rate divided by count rate, with `ignoring(le)` or `sum`.
- A threshold must be an existing bucket bound.
- Summary quantiles cannot be aggregated; histogram buckets can.
- Native histograms need no `le` in the aggregation.

<!-- astrona:playground:destroy -->
