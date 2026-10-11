---
draft: true
exam_objectives:
- Rates and Derivatives
---
# Counter Rates, Resets And Gauge Derivatives

Counters accumulate events and normally increase until their owning process or state resets. Gauges represent current values that can rise or fall as ordinary behavior. Rate and derivative functions must match that measurement contract. Applying a mathematically valid expression to the wrong type can produce a plausible but misleading graph.

## Rate And Increase Describe Counter Activity

The expression rate(http_requests_total[5m]) estimates average requests per second for each selected counter series over five minutes. It accounts for visible decreases as resets and extrapolates to the range boundaries according to the function's model. The result is an estimate based on collected samples rather than a complete event ledger.

Increase expresses estimated counter growth over the window. Conceptually, increase(counter[5m]) corresponds to rate(counter[5m]) multiplied by the window duration in seconds. It can return a non-integer result even when the underlying events were counted in integers because the range boundaries rarely align perfectly with observed samples and extrapolation is involved.

## Understand A Reset Scenario

Imagine one process exposes a counter that rises from 100 to 130, restarts, and then exposes 8. The drop is not negative traffic. A counter-aware function interprets the decrease as a reset and uses the visible increments under its calculation model. Events between a final pre-restart scrape and the actual restart can still be missing; reset correction cannot recover unobserved data.

A plain subtraction of the first value from the last would report a negative change and answer the wrong question. The producer's counter semantics, not merely the numeric shape of one window, justify using the reset-aware function.

## Calculate Before Combining Instances

Independent application replicas can reset at different times. Apply rate to each series before aggregating, as in sum by (service) (rate(http_requests_total[5m])). Summing raw counters first can hide one replica's decrease behind another replica's growth, preventing correct reset interpretation.

The grouping labels define the output population. Summing by service preserves that service dimension and removes other dimensions. Confirm that all selected counters describe the same event and unit before combining them. Adding a request counter to a byte counter is meaningless even if both increase.

## Irate And Window Choice

Irate uses the latest pair of samples in the selected range, making it responsive but more volatile than a longer-window rate. It can be useful for detailed rapidly changing views. Alerting commonly benefits from a less volatile rate window and a deliberate persistence policy rather than reacting to one sample pair.

A range needs enough collected samples to support the calculation. A window shorter than the practical scrape cadence can produce missing results or unstable estimates. A longer window smooths brief changes and may delay recognition of a fast-moving problem. Choose the window for the observation purpose rather than as a universal fixed constant.

## Gauges Need A Different Model

Delta estimates change across a range for gauges, while deriv uses linear regression to estimate their per-second trend. A queue depth can fall because work completed; treating that decrease as a counter reset invents activity. Conversely, a request counter's reset needs counter-aware handling rather than an ordinary gauge trend. Explain the measured quantity first, then select the function.

## Rate Before Fleet Aggregation

```promql
sum by (service) (rate(http_requests_total[5m]))
sum by (service) (increase(http_requests_total[5m]))
deriv(queue_depth[10m])
```

The first result has units of requests per second; the second estimates requests over five minutes. The third estimates a gauge trend in queued items per second. Each function must match the producer semantics, and the rate window needs enough source samples.

## Common pitfalls

> [!WARNING]
> Calculate rates before aggregating independent counters. Counter resets and ordinary gauge decreases have different meanings, and extrapolated increases are not exact reconstructed transaction counts.
