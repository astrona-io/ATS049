---
draft: true
exam_objectives:
- Aggregating over time
---
# Summary

A subquery turns an instant vector expression into a range vector. The syntax is `expr[range:step]`. Prometheus evaluates `expr` at every step time inside the range and collects the results as the points of a range vector, one list per series. An over_time function can then reduce that list. This makes it possible to ask for the peak, the lowest value or the average of a computed value, such as a summed rate, over a period.

The step is optional. When you leave it out, Prometheus uses the global evaluation interval of the server, which is 1 minute by default and 15 seconds in the playground. The evaluation times are not counted from the evaluation time of the outer query. They are the multiples of the step on the Unix time axis that lie inside the range, and the range is left-open and right-closed like every range. A step that does not divide the evaluation time therefore gives points that shift when the evaluation time moves. A range that holds only one step, such as `[1m:1m]`, gives one point.

Each evaluation of the inner expression behaves like an instant query. It uses the lookback delta of 5 minutes, so a series that has stopped can still return its last value for up to 5 minutes inside a subquery. When the inner expression contains `rate()`, each evaluation reads its own range of raw samples.

The order of the operations decides the result. The maximum over time of a sum is the highest total at any evaluation time, and the sum of the maximums adds peaks that happened at different times. Aggregation must come after `rate()`: the rate of a summed counter reads every restart of one instance as a reset of the whole sum and returns a value that is many times too large.

A subquery costs the number of step times multiplied by the cost of the inner expression, and nested subqueries multiply. A recording rule evaluates the expression once per evaluation interval and stores the result as a new series, so later queries read stored samples with a plain range selector. Use a subquery for exploration and for expressions that you run rarely. Use a recording rule for dashboards and alerts that run all the time.

Key facts:

- The default subquery step is the global evaluation interval of the server.
- The evaluation times of a subquery are multiples of the step, inside the left-open range.
- The number of evaluations is about the range divided by the step.
- Never take `rate()` of an aggregated counter. Take `rate()` first and aggregate afterwards.

<!-- astrona:playground:destroy -->
