---
draft: true
exam_objectives:
- Selecting Data
---
# Summary

An expression is always evaluated at one time. An instant vector selector returns, for each series, the newest sample in the window that ends at the evaluation time and starts five minutes earlier. The default window is the lookback delta. The window is left-open, so a sample exactly five minutes old is not used. A series with no sample in the window is absent from the result without an error, and the returned value can be up to five minutes old.

Staleness works with this rule. When a scrape stops returning a series, the server writes a stale marker, and the series leaves results at once instead of after five minutes. Data without markers, such as a backfilled block, loses a series only through the lookback rule. This is why a query for the current time returns nothing on data that is far in the past, and why a target that stopped reporting disappears five minutes after its last sample. A series with the value 0 is present, and a missing series is a different case.

The `offset` modifier moves one selector by a duration, a negative offset moves it forward, and `@` pins it to an absolute time in seconds. `@ start()` and `@ end()` pin it to the two ends of a range query. The modifiers follow the selector directly, apply to it alone and can be combined: the offset counts from the `@` time. A shifted selector still follows the lookback rule.

A range query evaluates the expression as an instant query at every step from the start time to the end time. The step is the distance between evaluations. The window is the duration of a range selector inside one evaluation. A step between samples uses the newest earlier sample, and a step longer than an event can hide it. Key facts:

- The lookback window is `(t - 5m, t]` by default.
- A stale marker removes a series at once.
- `offset` and `@` go directly after the selector, not after a function.
- A range query returns an instant vector or a scalar, never a bare range vector.

<!-- astrona:playground:destroy -->
