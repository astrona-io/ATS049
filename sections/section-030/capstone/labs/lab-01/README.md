---
estimated_duration: 30m
---

# Capstone: Aggregating Over Time

Graded integration lab for the whole section. The learner writes five PromQL expressions into the ConfigMap `answers` in `starfleet`: a plain over_time window, an `absent_over_time` check and three subqueries. Each grader runs the stored expression and a reference expression against Prometheus at a fixed time and compares labels and values. Status: UNTESTED (built without a live run; static checks only). The task is in `question.md` and the walkthrough in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-049-capstone-030
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-peak-disk-usage.sh` | q1 uses `max_over_time` on a plain 30 minute range and keeps both probe disks |
| `validate-silent-probe.sh` | q2 uses `absent_over_time` and returns the labels of the silent probe |
| `validate-queue-total-spread.sh` | q3 uses `stddev_over_time` on a subquery of the summed queue depth |
| `validate-peak-error-rate.sh` | q4 uses `max_over_time` on a subquery of the summed rate of status 500 responses |
| `validate-fewest-targets-total.sh` | q5 uses `min_over_time` on a subquery of `sum by (job) (up)` |
