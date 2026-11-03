---
estimated_duration: 20m
---

# Lab: Time-Shift Questions

**UNTESTED**: this lab was built without a live run. Static checks only.

Graded lab for the evaluation-time topic. The cluster starts with a Prometheus server that holds a fixed, generated dataset and a `shuttle` pod with the query helper. You store five PromQL expressions in a ConfigMap, and the grader runs each of them at a stated evaluation time and compares the result with a reference expression.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-049-lab-010-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1.sh` | queue_depth ten minutes before the evaluation time |
| `validate-q2.sh` | queue_depth pinned to 1767227385 |
| `validate-q3.sh` | growth of the shuttle queue since the start of a range |
| `validate-q4.sh` | shuttle queue ten minutes after the evaluation time |
| `validate-q5.sh` | probe-1 up five minutes before 1767228900 |

Each script reads the key from the ConfigMap `answers` (namespace `starfleet`), evaluates it and the reference expression at a fixed time and compares the result. `solution/apply.sh` writes the reference expressions.
