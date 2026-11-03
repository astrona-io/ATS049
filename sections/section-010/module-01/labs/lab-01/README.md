---
estimated_duration: 20m
---

# Lab: Select Exact Populations

**UNTESTED**: this lab was built without a live run. Static checks only.

Graded lab for the selector topic. The cluster starts with a Prometheus server that holds a fixed, generated dataset and a `shuttle` pod with the query helper. You store five PromQL expressions in a ConfigMap, and the grader runs each of them against Prometheus at one fixed evaluation time and compares the result with a reference expression.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-049-lab-010-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1.sh` | up series of the jobs bridge and shuttle |
| `validate-q2.sh` | 500 status request counters except shuttle-0 |
| `validate-q3.sh` | every series whose metric name starts with disk_ |
| `validate-q4.sh` | number of http_requests_total series per job |
| `validate-q5.sh` | last 30 seconds of the shuttle 200 counter |

Each script reads the key from the ConfigMap `answers` (namespace `starfleet`), evaluates it and the reference expression at a fixed time and compares the result. `solution/apply.sh` writes the reference expressions.
