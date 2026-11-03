---
estimated_duration: 20m
---

# Lab: Aggregation Operators With by And without

**UNTESTED.** This lab was built without a live run and has only had static checks. Graded lab for the aggregation operators. Prometheus holds a fixed dataset and the answers are PromQL expressions that you store in a ConfigMap. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-01/labs/lab-01
astrona destroy ats-049-lab-040-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1.sh` | Request rate per job |
| `validate-q2.sh` | CPU seconds per second by instance and mode |
| `validate-q3.sh` | Series count per metric name for job bridge |
| `validate-q4.sh` | Number of failed targets per job |
| `validate-q5.sh` | Request rate with every label except instance |

Every script reads one key of the ConfigMap `answers`, runs the expression and a reference expression at a fixed time, and compares result type, label sets and values.
