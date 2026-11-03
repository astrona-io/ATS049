---
draft: true
exam_objectives:
- Histograms
---

# Classic Histograms And histogram_quantile

A service that answers requests has more than one speed. Most requests are fast, a few are slow, and the average hides both. A histogram is the Prometheus metric type that records how many requests fell into each range of durations, so that you can later ask "how long did the slowest 10 percent of requests take?". PromQL answers that question with the function `histogram_quantile`, and the answer depends on how the buckets are built, how they are combined across instances, and what happens when a counter restarts.

Keep one sentence in mind for these lessons: **a classic histogram is a set of cumulative counters, one per upper bound, so you must take `rate` first, aggregate while you keep `le`, and only then ask for the quantile.**

The lessons run in this order. **What A Classic Histogram Exposes** reads the cumulative `le` buckets, the `_sum` series and the `_count` series of one histogram. **Rate Over Buckets And histogram_quantile** turns the bucket counters into a 90th percentile and shows how linear interpolation inside a bucket limits the accuracy. **Aggregating Buckets Across Instances** combines the buckets of several instances before the quantile, shows why a quantile of quantiles is wrong, and follows a counter reset.

## Learning objectives

After these lessons you can:

- Describe the series that one classic histogram creates and explain why bucket values are cumulative.
- Read `le` bucket, `_sum` and `_count` values and work out how many observations fell between two bounds.
- Write `histogram_quantile(0.9, sum by (le) (rate(...[5m])))` and say why each part is needed.
- Estimate by hand the value that linear interpolation returns, and say how wide the possible error is.
- Explain why averaging quantiles from different instances gives a wrong answer and aggregate buckets instead.
- Explain what a counter reset does to raw bucket values and why `rate` still gives a correct quantile.

## Before you start

You need to know instant vectors, label matchers, range vectors and the `rate` function. Everything here runs against Prometheus 3.5.5 in your playground.

The playground is a small Kubernetes cluster (created with `kind`) with a Prometheus server and a pod named `shuttle`. Prometheus does not scrape anything. It starts with one hour of generated data, one sample every 15 seconds, from Unix time 1767225600 to 1767229200. The newest sample is the default evaluation time of the helper.

You query through a helper in the `shuttle` pod. Every command in the lessons has this form:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

The helper runs one instant query at time 1767229200 and prints one line per series, as `name{label="value", ...} value`, with the labels sorted by name. A result without series prints `(empty result)`, a query error prints `error <type>: <message>`, and a scalar prints `scalar <value>`. The option `--time <unix seconds>` evaluates at another time. When a result has no metric name, the line starts with `{`.

The data for these lessons is the histogram `http_request_duration_seconds` with the label `handler="/orders"` on two instances, `bridge-0:8080` and `bridge-1:8080` of the job `bridge`. Each instance has six buckets with the upper bounds 0.05, 0.1, 0.25, 0.5, 1 and `+Inf` seconds. Per 15 seconds, `bridge-0` receives 200 observations and `bridge-1` receives 100. The instance `bridge-1` restarts at Unix time 1767227400, and all its counters start again from 0.

Numbers that depend on `rate` or on division are described as approximate, because the output can carry extra digits from floating-point arithmetic. Work them out first, then compare with your own output.

Launch your playground now, and keep it running next to you while you read:

<!-- astrona:playground -->
