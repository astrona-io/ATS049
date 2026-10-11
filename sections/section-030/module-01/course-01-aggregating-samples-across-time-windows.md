---
draft: true
exam_objectives:
- Aggregating over time
---
# Aggregating Samples Across Time Windows

PromQL can aggregate observations within a time window for each series. These functions answer questions such as the maximum queue depth seen recently or the average of collected temperature samples. They differ from aggregations that combine many series at one evaluation time. Both the dimension and measurement contract must be clear.

## Time Is The Aggregation Dimension

The expression max_over_time(queue_depth[10m]) selects ten minutes of samples for each queue-depth series and returns the largest observed value per series. It does not automatically find the largest value across every queue in the fleet. A separate cross-series operation would be needed to combine those results.

Min_over_time and avg_over_time similarly summarize the observed values inside each selected range. Count_over_time counts samples, not the events represented by their values. A range containing ten counter samples does not imply ten customer requests. The counter values describe accumulation, while the number of samples describes collection evidence.

## Choose The Function For The Quantity

For a gauge, a recent maximum can reveal a peak that a current sample no longer shows. A recent average can describe the collected values, and a minimum can identify a low point. For a counter, summing repeated cumulative values across time normally does not measure events in the window. Increase or rate provides the appropriate counter-oriented model.

Suppose a request counter exposes 100, 120 and 140. Adding those samples gives 360, but that number is not the number of requests between the observations. Much of the same accumulated history is counted repeatedly. Interpret the metric before selecting a time function based only on the desired English word total.

## Observed Samples Are Not Continuous Measurement

Many time-aggregation functions give each sample equal weight. Avg_over_time is therefore not universally an exact duration-weighted average when sampling is irregular. Missing collection intervals can bias the observed view. A maximum also reports the largest collected sample, which can miss a brief peak between scrapes.

Count_over_time can help reason about available observations, but the expected count depends on scheduling, scrape success and the window's boundaries. Present_over_time indicates whether there is any sample in a range for a selected series. Absence-oriented functions can support missing-data checks, but their resulting labels and expected population need careful interpretation.

## Derived Expressions Need History Too

A range selector directly applies to a series selector. A subquery can evaluate a derived expression across a range at a chosen resolution, producing a range input for another function. This enables questions about the recent behavior of an already calculated expression rather than only raw series values.

Subquery resolution is not the scrape interval. A fine resolution repeats calculations against available source evidence and increases query work without creating new observations. Broad nested expressions over long ranges can be expensive, so commonly used derived measurements may be suitable for recording rules with a deliberate evaluation schedule.

## Interpret The Result's Scope

A recent average might be useful for trend comparison while a recent maximum is useful for peak capacity review. Neither automatically gives the fraction of requests that met a latency target; that requires event or distribution evidence with an appropriate denominator. Explain the selected series, range, function and collection limitations so the result answers the intended operational question.

## Choose The Window Question

```promql
max_over_time(queue_depth[10m])
avg_over_time(queue_depth[10m])
count_over_time(queue_depth[10m])
```

These calculate a peak observed depth, a sample-based average and a count of observations, respectively. They do not calculate interchangeable versions of total work.

## Common pitfalls

> [!WARNING]
> Counting samples is not counting business events. Time averages reflect collected samples, and summing cumulative counter values across time repeatedly counts the same history.
