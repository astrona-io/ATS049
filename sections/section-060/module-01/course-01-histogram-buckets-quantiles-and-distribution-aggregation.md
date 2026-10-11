---
draft: true
exam_objectives:
- Histograms
---
# Histogram Buckets, Quantiles And Distribution Aggregation

A distribution describes how observations such as request duration vary. A mean can hide a slow tail, while a percentile estimates the boundary below which a chosen fraction of observations lies. Prometheus histograms and summaries provide different evidence for these questions, with important consequences for aggregation.

## Classic Histograms Have Cumulative Buckets

A classic histogram exposes bucket counters, a count and a sum. The le label identifies each bucket's upper boundary. A bucket at 0.3 seconds counts observations no greater than that boundary, and a larger bucket includes those same observations plus additional ones. The positive-infinity bucket covers all observations and corresponds to the count under the metric contract.

Buckets are therefore not independent disjoint categories. Adding their values together repeatedly counts observations. To estimate the fraction meeting a 0.3-second objective, divide the rate of the appropriate bucket by the rate of the count, using compatible population grouping. The choice of bucket boundary determines whether that threshold can be evaluated directly.

## Aggregate Distribution Evidence Correctly

A conceptual fleet percentile expression is histogram_quantile(0.95, sum by (service, le) (rate(http_request_duration_seconds_bucket[5m]))). Rate handles each bucket counter's resets before summation, and retaining le preserves the bucket structure. Selected instances must expose compatible buckets and measure the same quantity.

Removing le before the quantile calculation destroys the boundary information. Combining unrelated units or incompatible classic bucket layouts can also produce an invalid interpretation. Keep service or other required ownership labels so each output distribution represents the intended population.

## Quantiles Are Estimates

Histogram quantiles are estimated from bucket evidence using the function's interpolation rules. If a wide bucket contains the target percentile, the precise value within that bucket is not directly observed. More suitable bucket resolution near an important objective can improve usefulness, at the cost of additional classic series.

A percentile is not a maximum and does not describe every slow request. A 95th-percentile result leaves the slowest fraction outside that boundary. For an availability or latency objective, the proportion under a defined threshold can sometimes be more directly actionable than a moving percentile estimate.

## Mean Duration And Summaries

For compatible nonnegative duration observations, rate of the sum divided by rate of the count provides a mean over the selected window. Aggregate the numerator and denominator before dividing when combining unequal populations. Averaging per-instance means without weights has the same population problem as averaging error percentages.

A summary can expose client-calculated quantile estimates alongside sum and count. Those quantiles are not generally aggregatable into a fleet percentile. Averaging two 95th percentiles does not reconstruct the combined distribution. Sum and count can still support compatible mean calculations because they preserve additive evidence.

## Native Histograms Use Another Representation

Native histograms can store count, sum and buckets together in histogram samples rather than a collection of classic float bucket series. Their queries do not require a classic le dimension in the same way. Support depends on compatible instrumentation, collection, storage and query behavior. Understand the actual representation before copying a classic expression, and review annotations or limitations when sample types or bucket layouts are incompatible.

## Classic Histogram Calculation

```promql
histogram_quantile(0.95,
  sum by (service, le) (rate(http_request_duration_seconds_bucket[5m]))
)
```

The expression preserves classic bucket boundaries through le and estimates the service-level 95th percentile. It assumes compatible bucket layouts. A native histogram expression uses its histogram sample representation instead of this classic bucket-series structure.

## Common pitfalls

> [!WARNING]
> Classic buckets are cumulative. Preserve le for classic quantiles, calculate rates before aggregation and never average summary percentiles as if they described a combined distribution.
