---
draft: true
exam_objectives:
- Timestamp Metrics
---
# Summary

A timestamp-valued metric describes when an event occurred, while the sample timestamp describes when that value was observed. Their ages answer different questions.

Overdue-work monitoring needs an expected schedule, stable producer identity and explicit absence handling. Clock errors and scrape delays affect interpretation, and a fresh scrape can expose an old successful-event value without contradicting the collection evidence.
