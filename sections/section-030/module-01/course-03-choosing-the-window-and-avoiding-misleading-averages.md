---
draft: true
exam_objectives:
- Aggregating over time
---
# Choosing The Window And Avoiding Misleading Averages

Every over_time function gives a correct answer for the window you gave it, and the window is a choice that you make. A window that is too short returns nothing or one sample. A window that is too long hides a recent change. And some metrics should not be averaged at all, because the average of their raw values is a number with no meaning. This part shows how the window relates to the scrape interval and to the pattern in the data, and then shows the two most common wrong averages: the average of a counter and the average of a ratio.

## The window against the scrape interval

The **scrape interval** is the time between two samples of a series. In the dataset it is 15 seconds. A window of length `w` holds about `w / 15s` samples. Because the range is left-open and right-closed, a window of exactly one scrape interval holds exactly one sample at every evaluation time.

A window shorter than the scrape interval holds at most one sample, and depending on the evaluation time it can hold none. Evaluate a 10 second window at Unix time 1767229190. The newest sample before that time is at 1767229185, which is inside `(1767229180, 1767229190]`:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'count_over_time(queue_depth[10s])' --time 1767229190
```

You should see:

```text
{instance="bridge-0:8080", job="bridge"} 1
{instance="bridge-1:8080", job="bridge"} 1
{instance="shuttle-0:8080", job="shuttle"} 1
```

Move the evaluation time six seconds earlier, to 1767229184. The window is now `(1767229174, 1767229184]`, and no sample lies inside it, because the samples are at 1767229170 and 1767229185:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'count_over_time(queue_depth[10s])' --time 1767229184
```

You should see:

```text
(empty result)
```

The same query returned three series and then nothing, and only the evaluation time changed. A window that is shorter than the scrape interval gives results that flicker with the time of evaluation. Dashboards and alert rules evaluate at many different times, so the flicker shows up as gaps.

A safe rule is a window of at least four times the scrape interval, which is one minute for a 15 second interval. Four samples survive one missed scrape and still give a useful minimum, maximum or average. Functions such as `rate()` need at least two samples in the window, and the same rule keeps them working. Prometheus does not enforce any minimum for over_time functions, so the choice is yours.

## The window against the pattern in the data

A window also decides which events the answer can see. The gauge `queue_depth` of `bridge-0:8080` is a triangle wave. It rises from 10 to 30 and falls back to 10, and one full cycle takes 40 samples, which is 10 minutes. The newest sample at Unix time 1767229200 is a peak of 30, and the low point of 10 was 5 minutes earlier.

A five minute window ends 20 samples back, and the low point lies on its boundary or just outside it. Check the minimum with a five minute window:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'min_over_time(queue_depth{instance="bridge-0:8080"}[5m])'
```

You should see:

```text
{instance="bridge-0:8080", job="bridge"} 11
```

The low point of 10 was at 1767228900, exactly 5 minutes before the evaluation time. That timestamp is on the left boundary of `(t - 5m, t]`, so Prometheus 3 leaves it out, and the minimum is 11. With a ten minute window the low point is inside:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'min_over_time(queue_depth{instance="bridge-0:8080"}[10m])'
```

You should see:

```text
{instance="bridge-0:8080", job="bridge"} 10
```

Both answers are correct for their windows. A monitoring rule that wants to know the lowest queue depth must use a window that covers at least one full cycle of the gauge, which is 10 minutes here. When you do not know the cycle, look at a graph first. Choose the window from the question you ask, such as "in the last 10 minutes" or "since the last release", and then check that it holds enough samples.

Samples per window also matter for cost. A one hour window over 15 second samples reads 240 samples per series, and a query over many series multiplies that number. Run a count to see it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'count_over_time(queue_depth[1h])'
```

You should see:

```text
{instance="bridge-0:8080", job="bridge"} 240
{instance="bridge-1:8080", job="bridge"} 240
{instance="shuttle-0:8080", job="shuttle"} 240
```

The dataset holds 241 samples per series, from Unix time 1767225600 to 1767229200. The first one lies exactly one hour before the evaluation time, on the left boundary, so the window holds 240. Counting a window with `count_over_time` is a cheap way to check what a range selector really selects.

## Why the average of a counter misleads

A **counter** is a metric that only goes up while its process runs, such as `http_requests_total`. Its value is a running total since the process started. The average of running totals is the total at the middle of the window, which says nothing about how fast the counter grows. Compute `avg_over_time` for the successful GET requests of `bridge-0:8080`:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'avg_over_time(http_requests_total{instance="bridge-0:8080",method="GET",status="200"}[5m])'
```

The result should be 134575, from the dataset formula: the counter starts at 100000 and grows by 150 in every step, and the middle of the window is at step 230.5. The raw value at the evaluation time is 136000. Neither number says that this instance serves 10 requests per second. Two instances with the same traffic and different start times give different averages, and the average grows forever.

The number is also wrong in a second way when the counter restarts. The instance `bridge-1:8080` restarted at Unix time 1767227400, and its counters dropped to 0. An average that spans the restart mixes large values from before it with small values from after it. Evaluate the same function for its GET 200 counter at Unix time 1767227550, 150 seconds after the restart:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'avg_over_time(http_requests_total{instance="bridge-1:8080",method="GET",status="200"}[5m])' --time 1767227550
```

The dataset formulas predict 47040: nine samples near 104000 before the restart and eleven samples from 0 to 1200 after it. That value is far from every real value of the counter in the window. For a counter, use `rate()` or `increase()`, which read the growth between samples and add back the value before a reset. Their results here are about 10 requests per second for `bridge-0:8080` over any window without a restart.

A related question is the average of the rate of a counter over time, which is meaningful. It needs an expression inside the over_time function instead of a plain selector. A range selector works directly on a selector only, so `avg_over_time` cannot take `rate(...)` as its argument without extra syntax.

## Why the average of a ratio misleads

A **ratio** divides one quantity by another, such as the share of requests that fail. Suppose a service handled 100 requests in one minute and 10 failed, a ratio of 0.1. In the next minute it handled 10 requests and 5 failed, a ratio of 0.5. The average of the two ratios is (0.1 + 0.5) / 2 = 0.3. But 15 of 110 requests failed in total, which is about 0.136. The quiet minute got the same weight as the busy minute, and the average of the ratios is more than twice the true share. This example uses made-up numbers to show the arithmetic, not dataset values.

The correct approach is to add the numerators and the denominators over the whole window and divide once: the failed requests in the window divided by all requests in the window. For counters that means `increase()` of the errors divided by `increase()` of all requests, which is the same as the ratio of the two rates over the same window.

The `up` metric is a ratio of a special kind. Each sample is 1 or 0, so `avg_over_time(up[5m])` is the number of successful scrapes divided by the number of all scrapes, and every sample has the same weight because every scrape counts once. This average is exact. Run it for the time right after the outage of `shuttle-0:8080`:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'avg_over_time(up[5m])' --time 1767228600
```

The result for `shuttle-0:8080` should be 0.05, and for the other four targets 1. This is the same as the sum of 1 divided by the count of 20: one sample up out of 20. The rule is the same as for the ratio above: an average is correct only when every sample has the same weight in the question you ask.

You can now choose a window from the scrape interval and from the pattern in the data, and you know which values you must not average. What remains is combining functions: an average, a maximum or a quantile over a value that is itself the result of an expression.

## Common pitfalls

> [!WARNING]
> - Choosing a window shorter than the scrape interval. The result then depends on the evaluation time, and series come and go in the result.
> - Choosing a window shorter than the cycle of the gauge. A five minute window can miss the low point of a ten minute cycle, and the answer is still correct for its window.
> - Averaging a counter with `avg_over_time`. The result is the running total at the middle of the window, and it breaks at every restart. Use `rate()` or `increase()`.
> - Averaging ratios that have different denominators. Add the numerators and the denominators over the window, then divide once.
> - Forgetting that the left boundary is excluded. A window of exactly 5 minutes loses a sample that lies exactly 5 minutes back, and a window of exactly one hour holds 240 samples when the data is every 15 seconds.
> - Reading an empty result as a healthy value. An empty result means that the window held no sample for that series.
