---
draft: true
exam_objectives:
- Selecting Data
---
# The Four Label Matchers

A metric name alone selects every series of that metric. Real questions are narrower: only the production job, only the failing requests, everything except one instance. Label matchers narrow the selection. This part covers the four matchers, the exact rules for regular expressions and empty values, and selection by metric name.

## Two selectors, one difference

Start with an equality matcher. It goes in braces after the metric name:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up{job="bridge"}'
```

You should see:

```text
up{instance="bridge-0:8080", job="bridge"} 1
up{instance="bridge-1:8080", job="bridge"} 1
```

Now the opposite, with the negated matcher:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up{job!="bridge"}'
```

You should see:

```text
up{instance="probe-0:9100", job="probe"} 1
up{instance="shuttle-0:8080", job="shuttle"} 1
```

The PromQL engine takes the metric name and each matcher, and asks the TSDB for every series where all of them are true. A selector is an AND of its parts: a series must satisfy the name and every matcher. The two results above together make the four series of `up` that exist at this time, because `!=` selects exactly those series that `=` does not.

## The four matchers

PromQL has four matching operators:

| Operator | Selects series whose label value |
| --- | --- |
| `=` | is exactly equal to the string |
| `!=` | is not equal to the string |
| `=~` | matches the regular expression |
| `!~` | does not match the regular expression |

The right-hand side is always a string in quotes. Double quotes, single quotes and backticks all work. A backtick string is raw: backslashes in it have no special meaning, which is convenient for regular expressions.

A selector can use several matchers, separated by commas, and the same label can appear more than once. This selector asks for the `bridge` or `probe` jobs and then removes `probe`:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up{job=~"bridge|probe", job!="probe"}'
```

You should see:

```text
up{instance="bridge-0:8080", job="bridge"} 1
up{instance="bridge-1:8080", job="bridge"} 1
```

The result is the same as `up{job="bridge"}`. Each matcher narrows the previous result, and the order of matchers does not change the result.

## Regular expressions are fully anchored

A regular expression matcher uses the RE2 syntax of the Go language. It has alternation with `|`, groups, character classes and repetition. It has no lookahead and no backreferences. The matcher must match the whole label value, as if the expression started with `^` and ended with `$`. Prometheus adds the anchors itself. Test a partial pattern:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up{job=~"bri"}'
```

You should see:

```text
(empty result)
```

No job has the exact value `bri`, so nothing matches. To match a prefix, say so in the pattern:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up{job=~"bri.*"}'
```

You should see:

```text
up{instance="bridge-0:8080", job="bridge"} 1
up{instance="bridge-1:8080", job="bridge"} 1
```

This anchoring differs from what many people expect from tools such as `grep`, where a pattern may match anywhere in the text. In PromQL, `job=~"bri"` and `job="bri"` are equivalent. The negated matcher follows the same rule: `job!~"bridge|shuttle"` removes only the values that equal `bridge` or `shuttle` exactly. In Prometheus 3, the dot `.` also matches a newline character. A label value with a line break is rare, so this seldom matters, but `.*` really means any text.

## Absent labels count as empty

A series that does not have a label is treated as if the label had an empty value. This has a consequence that surprises many learners. A matcher that accepts the empty string also selects the series that lack the label. The metric `up` has no label `sensor`. Select with an empty `sensor`:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up{sensor=""}'
```

You should see:

```text
up{instance="bridge-0:8080", job="bridge"} 1
up{instance="bridge-1:8080", job="bridge"} 1
up{instance="probe-0:9100", job="probe"} 1
up{instance="shuttle-0:8080", job="shuttle"} 1
```

All four series come back, because none of them has a `sensor` label. The equality with the empty string is true for a missing label. Now use the empty-value rule on purpose: `temperature_celsius` has the label `sensor`, and no label `mountpoint`. The selector below finds the series of `temperature_celsius` that lack `mountpoint`:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'temperature_celsius{mountpoint=""}'
```

You should see:

```text
temperature_celsius{instance="probe-0:9100", job="probe", sensor="cpu"} 44
```

The negated form works the other way. `{sensor!=""}` selects only series that have a non-empty `sensor`, which is the usual way to ask "which series carry this label at all".

## A selector needs one non-empty matcher

Prometheus refuses a selector that could match every series with an empty label set. Every selector must contain a metric name, or at least one matcher that does not match the empty string. This query has only a matcher that accepts the empty string:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '{job=~".*"}'
```

The helper prints an error line that starts with `error bad_data` and says that the vector selector must contain at least one non-empty matcher. The reason is performance. The TSDB finds series through an index from label values to series, and a selector with only empty-matching matchers would have to read all series. Change `.*` to `.+`, which needs at least one character:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'count({job=~".+"})'
```

You should see:

```text
{} 56
```

The selector is now valid and selects every series that has a `job` label. The data has 68 series, and 56 of them have a sample in the last five minutes before the evaluation time. The other 12 belong to `probe-1`, which stopped reporting.

## Selecting by metric name

The metric name is the label `__name__`, and all four matchers work on it. A selector with `__name__` and no metric name in front selects across metrics. The next query selects two information metrics for one job:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '{__name__=~"build_info|team_info", job="shuttle"}'
```

You should see:

```text
build_info{instance="shuttle-0:8080", job="shuttle", version="2.0.1"} 1
team_info{instance="shuttle-0:8080", job="shuttle", team="logistics"} 1
```

The helper prints the name of each element in front of its braces. A name matcher is the tool for selecting a family of metrics, for example every metric that starts with `http_request_duration_seconds`, and it is also how you select a metric whose name collides with a PromQL keyword. The names `bool`, `on`, `ignoring`, `group_left` and `group_right` cannot be written as a plain selector, so you write `{__name__="on"}`. Selections across many names are expensive on a large server, because they cannot use the name to narrow the search. Use them with at least one other matcher when you can.

## What you now know

Matchers are an AND of conditions on label values: `=` and `!=` compare text, `=~` and `!~` use a fully anchored RE2 regular expression. A missing label equals an empty label, so a matcher that accepts the empty string also selects series that lack the label. A selector must hold a metric name or one matcher that cannot match an empty string, and `__name__` lets you select by metric name with the same four operators. You can predict a selection and check it with `count`.

The open question is what kind of value a selector produces. A bare selector is an instant vector. A selector followed by a duration in square brackets is a different type, and PromQL has two more types.

## Common pitfalls

> [!WARNING]
> - A regular expression is not a substring test. `job=~"bri"` matches nothing, because the pattern must match the whole value. Write `bri.*` for a prefix and `.*dge.*` for a substring.
> - `!=` and `!~` also keep series that do not have the label. `up{foo!="x"}` returns all series of `up`, because a missing `foo` is not equal to `x`.
> - `{job=~".*"}` is rejected, while `{job=~".+"}` is accepted. A selector with only matchers that accept the empty string never runs.
> - Special characters in a pattern need escaping, and in a double-quoted string the backslash must be doubled. Use a backtick string to avoid the doubling.
