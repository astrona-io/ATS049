---
draft: true
exam_objectives:
- Rates and Derivatives
---
# deriv() And predict_linear()

A disk that fills by one megabyte every second will be full some hours from now, and an on-call engineer wants the alert before that moment and not after it. A processor that heats up by 0.4 degrees every minute will cross a limit at a time that can be computed. Both questions need the speed of change of a gauge and a look into the future. `deriv()` gives the speed, and `predict_linear()` gives the value at a later time. This part runs both on a filling disk and a heating processor, and explains how they choose their line.

## deriv(): the slope of a gauge

`deriv()` calculates the **per-second derivative** of a gauge: how many units the value changes in one second. It does this with **simple linear regression**, a method that finds the straight line that has the smallest total squared distance to all samples in the range. The slope of that line is the result. It uses every sample in the range, and not only the first and the last one as `delta()` does. The documentation says that the range vector must hold at least two float samples.

The disk of `probe-0:9100` holds 40,000,000,000 bytes at the start of the dataset and grows by 15,000,000 bytes in every 15 second step. That is 1,000,000 bytes per second. First look at the newest value:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'disk_used_bytes'
```

You should see:

```text
disk_used_bytes{instance="probe-0:9100", job="probe", mountpoint="/"} 43600000000
```

Only `probe-0:9100` has a value at this time. The series of `probe-1:9100` stopped 10 minutes earlier, and a plain selector looks back only 5 minutes (the lookback delta). Now ask for the slope with a 15 minute range:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'deriv(disk_used_bytes[15m])'
```

The result should hold two series, with values close to 1000000 for `probe-0:9100` and 500000 for `probe-1:9100`. The second series is a surprise. A range selector does not use the 5 minute lookback. It takes every stored sample inside the range, and the last sample of `probe-1:9100` (Unix time 1767228600) is inside the 15 minute range, so the function still reports a slope for it. With a range of `10m` the sample on the left edge is excluded and only `probe-0:9100` remains. A range function can therefore report a series that no plain selector shows any more. Real Prometheus servers write a stale marker when a target disappears, which ends the series at once, but data that is stopped without a marker behaves like this.

## Why the temperature slope needs a unit

The temperature of `probe-0:9100` is 20 degrees plus 0.1 per step, so the slope is 0.1 divided by 15, about 0.00667 degrees per second. The unit is always "per second", and small numbers are hard to read. Multiply by 60 to get degrees per minute:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'deriv(temperature_celsius[10m]) * 60'
```

The value should be close to 0.4 for `probe-0:9100`. The multiplication does not change the labels. Only `probe-0:9100` appears, because the 10 minute range excludes the last sample of `probe-1:9100`, which sits exactly on the left edge.

## predict_linear(): a value in the future

`predict_linear(v range-vector, t scalar)` fits the same regression line, then returns the value that line has **`t` seconds after the evaluation time**. The line is anchored at the evaluation time, so the prediction is the fitted value now plus the slope times `t`. For `probe-0:9100`, the disk will hold 43,600,000,000 plus 1,000,000 times 3600 bytes in one hour, which is 47,200,000,000:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'predict_linear(disk_used_bytes[15m], 3600)'
```

The `probe-0:9100` value should be close to 47200000000. The value for `probe-1:9100` should be close to 43600000000: its line is carried 10 minutes past the last sample (41,500,000,000 plus 600 seconds of 500,000) and then one more hour (1,800,000,000). It is a prediction from old data, and an alert should not trust it.

## Time until the disk is full

You get the time to full by dividing the free space by the speed: (total - used) / slope. The free space needs two metrics, and the division matches series with the same labels:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '(disk_total_bytes - disk_used_bytes) / deriv(disk_used_bytes[15m])'
```

The result is in seconds. At the default time, `probe-0:9100` has 56,400,000,000 free bytes and a slope of 1,000,000 bytes per second, so the value should be close to 56400, which is about 15.7 hours. Only `probe-0:9100` appears, because the left side of the division has no value for `probe-1:9100`.

An alert states the same thing in a different form: "will the disk exceed its total in the next 24 hours, judged by the last hour". At Unix time 1767228600 both probes still have samples:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'predict_linear(disk_used_bytes[1h], 24 * 3600) > disk_total_bytes' --time 1767228600
```

The comparison keeps only series whose left value is greater than the right value, and keeps the left value. `probe-0:9100` is at 43,000,000,000 bytes and grows 86,400,000,000 bytes in a day, so its predicted value, close to 129400000000, is above 100,000,000,000 and the series stays. `probe-1:9100` reaches about 84,700,000,000 and is filtered out.

## What the range does to the line

A regression gives every sample the same weight, so a longer range reacts later to a change. The queue of `shuttle-0:8080` was flat at 0 and then grew by 2 per step from Unix time 1767227100. Compare a 10 minute range with a 1 hour range at the default time:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'deriv(queue_depth{instance="shuttle-0:8080"}[10m])'
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'deriv(queue_depth{instance="shuttle-0:8080"}[1h])'
```

The first value should be close to 0.1333 (2 per 15 seconds). The second should be close to 0.084, because the flat first part of the hour pulls the line down. A prediction ten minutes ahead gives about 360 with the short range and about 282 with the long one, while the real queue is already at 280. Choose a range that is long enough to smooth noise and short enough to hold only the trend you want to extrapolate.

You now know that `deriv()` returns a slope in units per second, that `predict_linear()` extends the fitted line, and that both read all samples in the range. The open question is how to count events inside the samples and how to choose the right function from all of them.

## Common pitfalls

> [!WARNING]
> - **Using `predict_linear()` on a counter.** A counter grows because of traffic and not on a straight line. Take `rate()` first, or use a gauge.
> - **Forgetting the unit.** `deriv()` is per second. A value of 0.00667 degrees per second is 0.4 degrees per minute.
> - **Trusting a prediction far beyond the data.** The line is straight, and real disks and temperatures are not. A 24 hour prediction from a 1 hour range is a warning, not a fact.
> - **A range that is too short or too long.** A short range follows noise. A long range reacts late to a change of speed.
> - **Expecting only live series.** A range function reports every series that has two samples in the range, even if the series has stopped. A plain selector looks back 5 minutes only.
