---
draft: true
exam_objectives:
- Aggregating over dimensions
---
# Summary

An aggregation operator combines many series of an instant vector into fewer series. `sum` adds the values, `min` and `max` pick the smallest and largest, `avg` divides the total by the number of series, `count` counts the series and ignores their values, and `group` returns `1` for each group. The operator runs once for every group, and every group produces one result series.

The grouping decides what the result looks like. `by (a, b)` keeps only the labels `a` and `b`. `without (a, b)` removes those labels and keeps all others. Aggregation also removes the metric name, unless `__name__` is named in `by`. A label that no series has does not cause an error: all series land in one group. An aggregation over an empty input returns an empty result, not `0`.

Counters are aggregated after they are turned into rates. The expression `sum by (instance, mode) (rate(node_cpu_seconds_total[5m]))` takes the per-second rate of every single series first, and then adds the rates. This order keeps each counter reset visible to `rate`. Adding raw counters first would turn a reset of one target into a fall of the total, and the rate of that total would be wrong. Aggregation also removes information, for example which core of a host is busy.

Counting is how you measure cardinality and target health. `count by (job) (up)` is the number of reporting targets, and `sum by (job) (up)` is the number of working ones. A target that stopped reporting disappears after the lookback period and appears in neither number, so the count must be compared with the expected number. A filter such as `up == 0` returns an empty result when nothing fails. A count of a count, such as `count(count by (team) (team_info))`, counts the distinct values of a label. Counting every series of a job or of the whole server shows where cardinality comes from.

Key facts to remember:

- `by` keeps the named labels, `without` drops the named labels.
- Aggregation drops the metric name and every label that is not kept.
- Always write `sum(rate(...))`, never the rate of a sum.
- `count` counts series, `sum(up)` counts working targets.
- A missing target is absent from the result; it does not show `0`.

<!-- astrona:playground:destroy -->
