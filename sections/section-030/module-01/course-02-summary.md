---
draft: true
exam_objectives:
- Aggregating over time
---
# Summary

Time aggregation evaluates the collected samples within each series window. It differs from grouping many series at one evaluation time, and its result depends on which observations were actually present.

Sample-based averages are not universally duration-weighted averages. Subqueries can provide history of a derived expression, but they add evaluation cost and cannot recover missing source measurements or turn repeated cumulative values into an event count.
