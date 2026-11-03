---
estimated_duration: 20m
---

# Lab: Subqueries And Nested Time Aggregation

Graded lab. Status: UNTESTED (built without a live run; static checks only). The learner writes four PromQL expressions into the ConfigMap `answers` in `starfleet`. Each grader runs the stored expression and a reference expression against Prometheus at a fixed time and compares labels and values. The task is in `question.md` and the walkthrough in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-049-lab-030-02
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-peak-queue-total.sh` | q1 uses `max_over_time` on a subquery of the summed queue depth at 1767227700 |
| `validate-peak-request-rate.sh` | q2 uses `max_over_time` on a subquery of the summed per-series rate at 1767227700 |
| `validate-fewest-targets-up.sh` | q3 uses `min_over_time` on a subquery of `min by (job) (up)` over 20 minutes |
| `validate-average-queue-total.sh` | q4 uses `avg_over_time` on a subquery of the summed queue depth over 30 minutes |
