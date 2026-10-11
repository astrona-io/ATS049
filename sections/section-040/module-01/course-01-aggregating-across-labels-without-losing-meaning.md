---
draft: true
exam_objectives:
- Aggregating over dimensions
---
# Aggregating Across Labels Without Losing Meaning

Aggregation across dimensions combines multiple time series at one evaluation time. The result depends both on the operation and the labels chosen for grouping. A graph with a single line can conceal a faulty population or weighting model, so explain what is combined and what information is intentionally removed.

## By And Without Define Output Identity

Sum by (service) combines series with the same service value and keeps that grouping dimension. Instance, route or status labels disappear unless included in the grouping. Sum without (instance) removes the instance dimension while preserving the other labels. These forms can yield different results when source series gain additional labels.

The selected operation applies to each group. Sum combines compatible quantities, avg computes an arithmetic average, count counts series and ranking operators select results according to values. Count of series is not the count of requests represented by counters. Topk selects the highest-valued series in a population and does not automatically describe their contribution to a total.

## Respect Measurement Semantics

Summing current queue sizes across queues can describe total queued items if the queues represent non-overlapping populations. Summing CPU usage across instances can describe fleet consumption under consistent units. Averaging a capacity percentage may need weighting if instances have different capacities. A syntactically valid aggregation is not necessarily a meaningful physical quantity.

For counters, compute the rate per source series before summing. Each process can reset independently, and aggregating raw values can hide those resets. The expression sum by (service) (rate(http_requests_total[5m])) preserves each source's reset interpretation before combining its estimated activity.

## Calculate Ratios From Compatible Totals

Suppose one instance serves 1,000 requests with 10 failures and another serves 10 requests with five failures. Their individual error ratios are 1% and 50%. The equal-weight average is 25.5%, but the combined population has 15 failures out of 1,010 requests, approximately 1.49%. The latter describes the fleet's request-weighted error ratio.

In PromQL, calculate summed failure rates divided by summed total request rates using the same grouping and compatible windows. The numerator must be a subset of the denominator's event population. Combining one service's failures with another service's total requests produces a number whose meaning is unsupported even if vector matching allows it.

## Preserve Useful Dimensions

An operational overview may aggregate instances while retaining service and environment. An alert needs labels sufficient for ownership, routing and distinguishing unrelated conditions. Removing every dimension can produce one global alert that hides a localized outage or cannot route to the responsible team.

Adding too many grouping labels can instead leave a fragmented result that no longer answers the fleet question. Choose the smallest set that preserves the intended population and subsequent decisions. Document how missing labels or new source dimensions affect by and without forms, especially when expressions are reused across changing instrumentation.

## Check The Resulting Population

Inspect which series contribute before accepting an aggregate. Duplicate scrape jobs, replica data and exporter identity conflicts can double-count observations. A missing instance can make the total smaller without indicating improved service. Pair the aggregation with collection coverage reasoning, and state whether the result represents all intended targets or only the currently observed subset.

## A Compatible Error Fraction

```promql
sum by (service) (rate(http_requests_total{status=~"5.."}[5m]))
/
sum by (service) (rate(http_requests_total[5m]))
```

Both sides retain the same service dimension and use the same counter window. The failures must belong to the total-request population. Zero traffic or an absent numerator needs a deliberate policy; this expression does not manufacture correctly labeled zeros for every missing service.

## Common pitfalls

> [!WARNING]
> Averaging percentages from unequal populations can misrepresent the fleet. Preserve meaningful labels, calculate counter rates before summing and ensure numerator and denominator describe compatible events.
