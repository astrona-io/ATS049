---
draft: true
exam_objectives:
- Selecting Data
---
# Selecting PromQL Data And Evaluation Time

PromQL begins by selecting labeled time series and then transforms them through functions and operators. A correct calculation can still answer the wrong question if the selector includes an unintended environment, omits a label or selects stale evidence. Explain the population and evaluation time before interpreting the numerical result.

## Select A Labeled Population

A selector such as http_requests_total{service="checkout",status=~"5.."} selects the counter series whose labels match both conditions. Equality requires the specified value, while regular-expression matching uses the complete label value. The expression does not modify stored labels or create a new instrumentation dimension.

Matchers that accept an empty value can also include series where that label is absent. A condition such as environment!="production" can therefore include unlabeled series. If a query requires a present non-empty environment label, express that requirement deliberately. A selector's apparent English meaning is not enough to establish its exact population.

## Distinguish Vector Types

An instant vector contains one eligible sample per selected series at an evaluation time. A range vector contains a window of samples for each selected series. The selector http_requests_total[5m] is a range vector suitable as input to functions such as rate. It is not itself a five-minute dashboard schedule.

A scalar is a single numerical value without a labeled population. Functions and operators have type requirements, so a raw range vector cannot be used everywhere an instant vector is expected. Understanding the input type is often more useful than guessing a syntax change until an expression parses.

## Range Queries Repeat Evaluation

An instant query evaluates an expression once. A range query evaluates an expression at a sequence of times between its start and end, according to the chosen step. An expression such as rate(http_requests_total[5m]) still uses a five-minute window at each step. The range query's overall duration and the expression's internal range are different settings.

A long step can hide brief behavior in the displayed result, while a short step does not create source observations between scrapes. Dashboard resolution therefore changes the evaluated view rather than the collector's sample history. Use a range duration that fits the measurement and available scrape cadence.

## Understand Lookback And Staleness

Instant selectors choose eligible recent samples under lookback and staleness rules. A target that stops exposing a series can disappear from current selection while historical samples remain in storage. Absence is not the value zero. A query that replaces every absent series with zero can conceal lost collection and produce an unjustified healthy interpretation.

Range functions use the samples in their selected windows according to their own semantics. A window containing too few samples may not support a meaningful rate. Check the available evidence and target lifecycle when a result is missing rather than immediately assuming the service has no activity.

## Move The Selection Time Explicitly

The offset modifier shifts a selector relative to evaluation time, allowing comparison with earlier periods. The @ modifier can select data at an explicit evaluation timestamp where supported. These affect query selection rather than metric units or scrape configuration. A comparison with earlier history also needs stable grouping and awareness of changes in labels or target membership.

For example, comparing current checkout traffic with an hour earlier can be useful, but a deployment that changed service labels may change the selected population. Preserve the intended identity and describe what each side actually measures before treating the difference as a behavioral change.

## Read A Selector

```promql
http_requests_total{service="checkout",status=~"5.."}
rate(http_requests_total{service="checkout"}[5m])
rate(http_requests_total{service="checkout"}[5m] offset 1h)
```

The first expression selects current counter samples for the matching failures. The second produces per-series rates over the recent window. The third shifts that source window one hour into earlier history. These expressions assume the named metric and bounded labels exist; they are illustrative queries, with no claimed runtime result.

## Common pitfalls

> [!WARNING]
> A range query and a range vector are different concepts. Matchers can include absent labels, and query resolution cannot create samples that were never collected.
