---
draft: true
exam_objectives:
- Rates and Derivatives
---
# Summary

A gauge is a metric that can rise and fall, such as a queue depth, a temperature or the bytes used on a disk. The counter functions assume that a drop means a restart, so they give wrong, positive results for a gauge that falls. Gauges have their own functions, and the type of the metric, not its name, decides which family to use.

`delta()` subtracts the first sample of the range from the last, extrapolates to the full range and may be negative or fractional. `idelta()` subtracts the last two samples and is exact. Neither has reset logic. `deriv()` returns the per-second slope of a gauge. It uses simple linear regression, which fits one straight line to every sample in the range. `predict_linear()` returns the value that this line has a given number of seconds after the evaluation time. Dividing the free space of a disk by the slope of the used space gives the time until the disk is full in seconds.

The range decides the line. A short range follows noise and a long range reacts late to a change of speed. A forecast that is far ahead of the data is a warning and not a fact. A range function reports every series that has at least two samples in the range, even a series that a plain selector no longer shows because of the five minute lookback.

`changes()` counts the number of times the value is different between two consecutive samples and works for every metric type. `resets()` counts the decreases between consecutive samples. It counts restarts for a counter, and it counts every normal fall for a gauge.

Key facts:

- Counter functions: `rate()`, `increase()`, `irate()` and `resets()`.
- Gauge functions: `delta()`, `idelta()`, `deriv()` and `predict_linear()`.
- `changes()` works on any metric type and returns a count.
- `deriv()` and `predict_linear()` need at least two samples in the range.
- The result of `deriv()` is per second. Multiply by 60 or 3600 for minutes or hours.
- Time until full equals free space divided by the slope of used space.

<!-- astrona:playground:destroy -->
