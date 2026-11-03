---
estimated_duration: 25m
---

# Lab: topk, bottomk, quantile, count_values And Statistics

**UNTESTED.** This lab was built without a live run and has only had static checks. Graded lab for ranking and statistics. Prometheus holds a fixed dataset and the answers are PromQL expressions that you store in a ConfigMap. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-049-lab-040-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1.sh` | Two busiest instances by request rate |
| `validate-q2.sh` | Series with the lowest queue_depth in each job |
| `validate-q3.sh` | Median queue_depth across instances |
| `validate-q4.sh` | How many targets have each up value |
| `validate-q5.sh` | Error ratio of the bridge job without averaging |
| `validate-q6.sh` | Average request duration across instances |

Every script reads one key of the ConfigMap `answers`, runs the expression and a reference expression at a fixed time, and compares result type, label sets and values.
