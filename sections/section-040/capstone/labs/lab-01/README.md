---
estimated_duration: 30m
---

# Lab: Aggregating Over Dimensions Capstone

**UNTESTED.** This lab was built without a live run and has only had static checks. Capstone for the aggregation section. It combines grouping with `by`, ranking, statistics, counting and correct ratios. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-049-capstone-040
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1.sh` | Weighted error ratio for each job |
| `validate-q2.sh` | Lowest up value per job during the shuttle failure |
| `validate-q3.sh` | Instance with the highest request rate |
| `validate-q4.sh` | Standard deviation of queue_depth per job |
| `validate-q5.sh` | Number of CPU cores per instance |

Every script reads one key of the ConfigMap `answers`, runs the expression and a reference expression at a fixed time, and compares result type, label sets and values.
