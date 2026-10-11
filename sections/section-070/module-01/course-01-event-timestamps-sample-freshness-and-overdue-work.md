---
draft: true
exam_objectives:
- Timestamp Metrics
---
# Event Timestamps, Sample Freshness And Overdue Work

Many operational questions concern freshness: when a backup last succeeded, whether a batch job is overdue or whether a target's observations are current. Prometheus can represent event timestamps as ordinary gauge values. These must be distinguished from sample timestamps, which describe when the numerical values were observed or supplied under the collection contract.

## Two Clocks Describe Different Facts

A gauge named batch_last_success_timestamp_seconds can hold the Unix time of a successful batch completion. Prometheus later scrapes that value and attaches a sample timestamp. A fresh sample can therefore contain an old event time. The scrape succeeded recently, but the batch has not succeeded recently.

The function timestamp(metric) returns the timestamp associated with selected samples. It does not interpret the metric's value as an event time. Confusing these clocks can produce an alert that reports fresh collection while missing an overdue operation, or the reverse. The metric's documented unit and meaning establish which question the value answers.

## Calculate Event Age Explicitly

The expression time() - batch_last_success_timestamp_seconds conceptually compares current evaluation time with the stored event time. The result describes elapsed seconds since the reported success. A threshold should reflect the job's schedule and acceptable delay rather than an arbitrary scrape interval.

For example, a daily backup may need a tolerance for its expected completion window. A five-minute age threshold would declare it overdue through most of its normal lifecycle. A job that runs every few minutes requires a different boundary. Define the operational expectation first, including planned pauses and maintenance responsibilities.

## Preserve Identity And Absence Meaning

A last-success value needs a stable identity that identifies the intended job or service. An instance label that changes on every run can leave old series and make the current population unclear. Gateways retaining batch results need explicit lifecycle management so abandoned groups do not masquerade as current producers.

If the metric is absent, the age expression may produce no result. That is different from a large age value. The monitoring design should decide whether absence means never completed, unavailable collection or intentionally removed work. A separate coverage or absence check may be needed; replacing everything with zero can hide the distinction.

## Account For Clock And Collection Error

Producer and evaluator clocks can differ. A timestamp reported in the future can yield a negative age, while a badly delayed clock can make current work appear old. Time synchronization and the source of the event timestamp therefore matter. State the uncertainty instead of interpreting every numerical age as exact.

Scrape delay also affects when a new event-time value becomes visible. A successful operation shortly after a scrape will not appear until later collection. Alert duration and threshold should accommodate the intended collection cadence without allowing an excessive stale period. A dashboard refresh cannot make the collector learn about the event earlier.

## Distinguish Freshness From Success Quality

A recent successful-event timestamp proves only the producer's stated success under its definition. It does not establish that backup restoration works or that every expected record was processed. Use separate outcome evidence where needed. The timestamp is a useful freshness signal within a broader contract that includes correct success criteria, coverage and lifecycle.

## Two Different Freshness Questions

```promql
time() - batch_last_success_timestamp_seconds
time() - timestamp(batch_last_success_timestamp_seconds)
```

The first measures age of the reported successful event. The second measures age of the selected sample. Recent collection can make the second small while the first is large. The examples assume event values use Unix seconds.

## Common pitfalls

> [!WARNING]
> Sample freshness and event age are different measurements. Missing event-time series do not automatically become overdue values, and clock errors can invalidate literal age interpretation.
