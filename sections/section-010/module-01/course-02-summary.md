---
draft: true
exam_objectives:
- Selecting Data
---
# Summary

PromQL selectors identify a labeled population and the samples eligible at an evaluation time. Instant vectors contain one selected sample per series, while range vectors contain windows of samples for range functions.

A range query repeats evaluation across steps rather than changing that type model. Matchers, offset and staleness determine the actual evidence selected; missing series and empty-compatible labels require deliberate interpretation.
