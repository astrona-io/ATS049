---
draft: true
exam_objectives:
- Aggregating over dimensions
---
# Summary

`topk` and `bottomk` select series instead of calculating a new value. They keep the k series with the highest or lowest values and return them with the metric name and every original label. With `by` or `without` they rank inside each group, but the clause only forms the groups and does not change the result labels. A group with fewer than k series returns all of them. When values are tied at the cut, the choice among them is not defined. The ranking runs again at every evaluation time, so the winner changes over a time range. Rank rates, not raw counters, because a counter shows how long a process has run.

`quantile(φ, v)` sorts the values of the series in a group and returns the value at position φ, between 0 and 1, interpolating between neighbours. It describes the distribution of instances and is not the same as `histogram_quantile`, which estimates a quantile of measurements from histogram buckets, or `quantile_over_time`, which works on one series over time. A φ outside 0 to 1 returns an infinite value. `stddev` and `stdvar` give the population standard deviation and variance, and show how unevenly the instances behave. `count_values("label", v)` counts how many series have each distinct value and returns one series per value, with the value as text in the new label.

An average is only correct when every series has the same weight. The average of per-instance averages or ratios is wrong when the instances carry different load. The correct form sums the numerators and the denominators separately and divides once, for example the rate of the duration sum divided by the rate of the observation count. Both sides of a division need the same labels after aggregation.

An aggregate removes detail, and the removed detail can be a failure. An average of `up` stays high while one instance is down, and an instance without a series is invisible to `avg`, `sum` and `max`. Use `min`, `max`, a filter such as `up == 0`, `topk` or a count compared with the expected number to find failing instances.

Key facts to remember:

- `topk` and `bottomk` keep all labels, and `by` only forms ranking groups.
- Ties at the cut have no defined order.
- `quantile`, `stddev`, `stdvar` and `count_values` work across series at one evaluation time.
- Sum numerators and denominators first, then divide.
- Do not use `avg` to detect a failing or missing instance.

<!-- astrona:playground:destroy -->
