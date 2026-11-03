---
draft: true
exam_objectives:
- Binary operators
---

# Summary

Between two instant vectors, a binary operator must decide which sample belongs with which. Prometheus solves this with matching: each series on one side is paired with a series on the other side that has the same labels, and the operator runs on the pair.

## What you learned

By default the match is one-to-one. Two series pair when all their labels are equal, and the metric name is not compared. A series without a partner is dropped without an error. When the label sets differ in a label such as `status`, a plain operator returns an empty result. The modifier `ignoring(label)` leaves the listed labels out of the comparison. The modifier `on(label)` compares only the listed labels. In a one-to-one result, `ignoring` removes the listed labels from the left series, and `on` keeps only the listed labels. If more than one series on either side has the same match labels, Prometheus returns an error, because it cannot pick a partner.

A many-to-one match pairs several series on one side with a single series on the other side, for example every request counter of an instance with the one `build_info` series of that instance. The modifier `group_left` says that the left side is the many side, and `group_right` says that the right side is. The result keeps the labels of the many side. Labels named in the parentheses are copied from the one side into the result. This is how a label such as `version` or `team` is attached to a metric that does not have it. The one side must still have only one series for each match, and a label cannot appear in both the `on` list and the group list.

The set operators work on whole label sets. `and` keeps the left series that have a partner on the right. `unless` keeps the left series that have no partner on the right. `or` keeps all left series and adds the right series that have no partner on the left. The operators ignore the values on the right: a right sample with the value 0 still counts as a partner. They return the left sample with its name, and they work only between instant vectors.

The key facts to remember are these:

- Matching compares all labels except the metric name, unless `on` or `ignoring` says otherwise.
- `ignoring(x)` and `on(x)` change which labels are compared, and they change which labels remain in a one-to-one result.
- `group_left` names the many side on the left, and `group_right` names it on the right; the labels in the parentheses come from the one side.
- A match group may have only one series on the one side, or the query fails.
- `and`, `or` and `unless` look at labels, not at values; put a comparison on the right side to select by value.

<!-- astrona:playground:destroy -->
