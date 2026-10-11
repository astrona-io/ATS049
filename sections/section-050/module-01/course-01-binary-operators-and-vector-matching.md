---
draft: true
exam_objectives:
- Binary operators
---
# Binary Operators And Vector Matching

PromQL binary operators combine expressions through arithmetic, comparisons or set operations. When vectors are involved, labels determine which series can interact. A missing result often reflects an unmatched population rather than a numerical calculation of zero. Understanding this matching contract is essential for ratios and metadata joins.

## Arithmetic Needs A Defined Pair

A vector combined with a scalar applies the operation to applicable samples. Vector-to-vector arithmetic normally matches series whose relevant label sets agree. Two vectors with different remaining dimensions may not pair even if their metric names sound related. A numerator grouped by service and status does not automatically match a denominator grouped only by service.

For an error ratio, first define compatible event populations and grouping. Then determine whether matching needs an explicit modifier. The purpose is to express the intended relationship, not merely make an expression return something. An accidental match across environments can produce a plausible number with no operational meaning.

## Comparisons Can Filter Or Return Boolean Values

A comparison such as queue_depth > 100 normally retains the samples satisfying the condition rather than changing their values to one. The bool modifier changes applicable comparison results to numerical zero or one under its matching rules. That distinction matters when a result is later aggregated or used as an alert expression.

An alert expression fires based on returned series, not simply on a belief that any numeric zero is false. Using a bool comparison without a further condition can leave zero-valued series present. Understand the alert evaluator's presence model before replacing a filtering comparison with a boolean one.

## Choose Matching Dimensions Explicitly

On lists labels that participate in matching. Ignoring removes listed labels from the match comparison. These modifiers do not rewrite source history. They establish how the current operation pairs results. If additional labels appear in the source later, the chosen matching model determines whether the expression remains valid.

Many-to-one arithmetic can use group_left when several left-hand series match one right-hand series. Group_right describes the corresponding opposite direction. The side intended to be one must be unique for each match key. A group modifier does not authorize arbitrary ambiguous many-to-many arithmetic, and duplicate metadata series can therefore make a previously working join fail.

## Set Operators Describe Presence

And, or and unless operate on vector membership under their matching rules. They are useful for including, combining or excluding labeled populations. They should not be interpreted as ordinary arithmetic on the sample values. An or expression can supply a fallback population, but a scalar-like fallback does not automatically create one correctly labeled zero for every missing service.

Missing data and zero activity require different models. If a denominator is zero, division can produce special numerical results rather than a meaningful error fraction. If the denominator series is absent, matching can remove the result entirely. Design alerts to distinguish low traffic, no traffic and lost collection where those states matter.

## Review Before Adding A Modifier

Inspect each side's labels, units and expected cardinality. Confirm that the numerator and denominator refer to the same ownership and time window. Then use the narrow matching rule that expresses the relationship. Treat matching errors as evidence about instrumentation or grouping rather than bypassing them with broad modifiers that conceal an undefined population.

## A Many-To-One Relationship

```promql
request_errors_per_second
/ ignoring (status) group_left
request_total_per_second
```

Assume the left side has service and status labels, while the right side has exactly one series per service. Ignoring status permits that match and group_left retains the left-side population. Duplicate right-side service matches make the relationship ambiguous. The metric names here stand for previously defined compatible derived measurements.

## Common pitfalls

> [!WARNING]
> A group modifier requires a unique matching side. Bool comparisons leave present zero-valued results, and unmatched series are not automatically numerical zero.
