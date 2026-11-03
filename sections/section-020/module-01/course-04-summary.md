---
draft: true
exam_objectives:
- Rates and Derivatives
---
# Summary

A counter is a total that only grows while its process runs. The raw value says little, so PromQL reads the samples inside a left-open, right-closed range and turns them into a speed or a count. The range must hold at least two samples, and a safe size is four times the scrape interval or more. A longer range gives a smoother result and a shorter range reacts faster.

`rate()` returns the per-second average increase over the range. It subtracts the first sample from the last, extrapolates to the edges of the range and divides by the range in seconds. `increase()` is the same calculation without the final division, so it returns the number of events in the range, and it can be fractional. `irate()` uses only the last two samples in the range, does not extrapolate, and follows short spikes. Use `rate()` for alerts and recording rules, `increase()` for counts and `irate()` for zoomed-in graphs.

Prometheus reads every drop between two consecutive samples as a counter reset. It adds back the value before the drop, so `rate()` and `increase()` stay positive across a restart, and they lose about one step of growth for each reset. `delta()` has no reset logic and shows a restart as a large negative change, and `irate()` shows 0 for one step.

Aggregation comes after the rate. `sum(rate(x[5m]))` repairs each series separately. `rate()` of a summed series sees only the drop of the total and gives a wrong, much larger value. With `by` you keep the listed labels, and with `without` you remove the listed labels and keep the others.

Key facts:

- A range such as `[5m]` holds the samples with a timestamp greater than `t - 5m` and up to `t`.
- `rate()` returns events per second, and `increase()` returns events in the range.
- `increase(x[R])` equals `rate(x[R])` multiplied by the seconds in `R`.
- A range with fewer than two samples gives no result for the series.
- The correct order is `sum(rate(...))`.

<!-- astrona:playground:destroy -->
