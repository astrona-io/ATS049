---
draft: true
exam_objectives:
- Selecting Data
---
# Summary

Prometheus stores samples in time series. A series is identified by its metric name and its set of labels, and the name is itself the label `__name__`. A selector asks the storage for the series that match, and the PromQL engine returns one sample for each series that has a recent sample. Series without one are left out of the result without an error.

Four matchers narrow a selection: `=` and `!=` compare text, and `=~` and `!~` use a regular expression that must match the whole value. A selector is an AND of all its parts. A label that a series does not have counts as an empty value, so a matcher that accepts the empty string also selects the series that lack the label. Every selector needs a metric name or at least one matcher that cannot match the empty string. The matchers also work on `__name__`, which selects across metrics.

Every expression has one of four types: instant vector, range vector, scalar or string. A selector returns an instant vector. A duration in square brackets after a selector returns a range vector, whose window is left-open and right-closed. Durations use the units `ms`, `s`, `m`, `h`, `d`, `w` and `y` and may be combined from the largest unit to the smallest. Functions and aggregations accept only certain types, and a type mismatch is an error.

`count` returns the number of series in an instant vector, and `count by` returns one number for each value of a label. Counting is the check that proves a selector picked the intended population. Key facts:

- A series is identified by its name and label set; a new label value makes a new series.
- Regular expression matchers are fully anchored.
- A selection that matches nothing makes `count` return an empty result, not 0.
- A range selector in Prometheus 3 excludes the sample exactly one duration before the evaluation time.

<!-- astrona:playground:destroy -->
