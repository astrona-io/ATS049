---
draft: true
exam_objectives:
- Binary operators
---

# Summary

A binary operator combines two operands into one result. In PromQL an operand is a scalar or an instant vector, and a range vector is never allowed. Arithmetic, comparison and set operators all follow the same idea: the operator is applied to the values, and the labels of the result depend on the kind of operator.

## What you learned

Arithmetic operators are `+`, `-`, `*`, `/`, `%`, `^` and `atan2`. Between a scalar and a vector the operator is applied to every sample, and each series keeps its labels. Between two instant vectors the operator is applied to pairs of samples that have the same labels, and series without a partner are silently dropped. Every arithmetic operation removes the metric name, because the new value is no longer the original metric. The remaining labels stay, so the result is still identified by `job`, `instance` and the other labels.

Comparison operators are `==`, `!=`, `>`, `<`, `>=` and `<=`. By default they filter: a series stays with its original value when the comparison is true and disappears when it is false. The metric name stays too. The `bool` modifier changes the behaviour: every series stays, the value becomes 1 or 0, and the metric name is removed. Two scalars have nothing to filter, so a comparison between scalars is only valid with `bool`.

Precedence decides the order in an expression without parentheses. From highest to lowest it is `^`, then `*`, `/`, `%` and `atan2`, then `+` and `-`, then the comparisons, then `and` and `unless`, then `or`. Operators on the same level run from left to right, except `^`, which runs from right to left. Parentheses override all of this and make an expression easier to read.

Division follows the floating point rules of IEEE 754. A positive number divided by zero gives `+Inf`, a negative number gives `-Inf`, and zero divided by zero gives `NaN`. NaN is not equal to anything, including itself, so every comparison with NaN is false except `!=`. A filter with a comparison therefore removes NaN series, and `bool` turns them into 0. When one side of a division has no series at all, the result is empty and not zero.

The key facts to remember are these:

- Arithmetic drops the metric name; a filtering comparison keeps it; `bool` drops it.
- A comparison between two scalars needs `bool`.
- `^` is right associative, and every other arithmetic operator is left associative.
- Aggregate both sides of an error ratio with the same `by` clause so that the labels match.
- `x / 0` is `+Inf`, `-Inf` or `NaN`, and a comparison filter removes `NaN`.

<!-- astrona:playground:destroy -->
