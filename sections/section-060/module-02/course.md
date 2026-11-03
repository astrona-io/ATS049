---
draft: true
exam_objectives:
- Histograms
---

# Means, Fractions And Native Histograms

A histogram holds more than quantiles. Its `_sum` and `_count` series give the mean duration, and its buckets give the share of requests that were fast enough, which is the number behind many service level objectives (SLOs). This part of the course also compares histograms with summaries, the other metric type that records distributions, and introduces native histograms, the newer representation that replaces the many `_bucket` series with one sample.

Keep one sentence in mind: **a mean is a ratio of two rates, a share is a ratio of two bucket rates, and in both cases you add the numerator and the denominator of all instances before you divide.**

The lessons run in this order. **Mean Duration From Sum And Count** divides the rate of `_sum` by the rate of `_count`, per instance and for the whole service, and shows why an average of means is wrong. **Share Of Requests Under A Threshold** reads a bucket as a threshold and divides it by the total, with the label matching that this needs. **Histograms, Summaries And Native Histograms** compares the metric types and explains how native histograms change the queries. It is a reading lesson without commands, because the dataset has no native histograms.

## Learning objectives

After these lessons you can:

- Compute the mean duration with `rate(_sum) / rate(_count)` per instance and for all instances together.
- Explain why a mean of means is wrong and why the ratio must be taken after the sums.
- Compute the share of requests at or under a bucket bound, and the share above it.
- Use `ignoring(le)` to divide a bucket series by a series without `le`.
- Explain why a threshold must be an existing bucket bound.
- Compare histograms and summaries for aggregation, accuracy and cost.
- Describe native histograms, how their queries differ from classic ones, and how the quantile function treats them.

## Before you start

You need to know instant vectors, `rate`, aggregation with `sum by` and the bucket layout of a classic histogram: cumulative `le` buckets, `_sum`, `_count`, and `+Inf` equal to the count.

The playground is a small Kubernetes cluster (created with `kind`) with a Prometheus server and a pod named `shuttle`. Prometheus does not scrape anything. It starts with one hour of generated data, one sample every 15 seconds, from Unix time 1767225600 to 1767229200, and the newest sample is the default evaluation time.

You query through a helper in the `shuttle` pod. Every command has this form:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

The helper runs one instant query at time 1767229200 and prints one line per series, as `name{label="value", ...} value`, with the labels sorted by name. A result without series prints `(empty result)`, a query error prints `error <type>: <message>`, and a scalar prints `scalar <value>`. The option `--time <unix seconds>` evaluates at another time.

The data is the histogram `http_request_duration_seconds` for `handler="/orders"` on `bridge-0:8080` and `bridge-1:8080`. The bounds are 0.05, 0.1, 0.25, 0.5, 1 and `+Inf` seconds. Per 15 seconds, `bridge-0` records 200 observations with a total duration of 30 seconds, and `bridge-1` records 100 observations with a total of 40 seconds. Per step, the cumulative bucket counts are 60, 120, 170, 190, 198 and 200 for `bridge-0` and 10, 40, 80, 95, 99 and 100 for `bridge-1`. The instance `bridge-1` restarts once, long before the default time.

Numbers that depend on `rate` or on division are described as approximate, because the output can carry extra digits from floating-point arithmetic. Work them out first, then compare.

Launch your playground now, and keep it running next to you while you read:

<!-- astrona:playground -->
