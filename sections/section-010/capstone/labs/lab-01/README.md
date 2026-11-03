---
estimated_duration: 30m
---

# Lab: Selecting Data Capstone

**UNTESTED**: this lab was built without a live run. Static checks only.

Capstone lab for the Selecting Data section. The cluster starts with a Prometheus server that holds a fixed, generated dataset and a `shuttle` pod with the query helper. You store five PromQL expressions in a ConfigMap. They mix the label matchers, selection by metric name, range selectors, counting, `offset` and `@`. The grader runs each expression at a stated evaluation time and compares the result with a reference expression.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-049-capstone-010
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1.sh` | count of 5xx request series per instance |
| `validate-q2.sh` | probe up series ten minutes ago |
| `validate-q3.sh` | five minutes of bridge-1 queue_depth ending at 1767227400 |
| `validate-q4.sh` | series count per job ten minutes after the evaluation time |
| `validate-q5.sh` | up and build_info of shuttle-0 at 1767228300 |

Each script reads the key from the ConfigMap `answers` (namespace `starfleet`), evaluates it and the reference expression at a fixed time and compares the result. `solution/apply.sh` writes the reference expressions.
