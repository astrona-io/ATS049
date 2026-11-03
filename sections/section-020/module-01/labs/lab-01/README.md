---
estimated_duration: 25m
---

# Lab: Counters, rate And increase

Graded lab. Status: UNTESTED (built without a live run; static checks only). The learner writes five PromQL expressions into the ConfigMap `answers` in `starfleet`. Each grader runs the stored expression and a reference expression against Prometheus at a fixed time and compares labels and values. The task is in `question.md` and the walkthrough in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-049-lab-020-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-request-rate-per-instance.sh` | q1 uses `rate()` and `without` and returns the rate per instance and job |
| `validate-error-increase-per-instance.sh` | q2 uses `increase()` over 10 minutes for status 500, per instance |
| `validate-bridge-rate-across-restart.sh` | q3 uses `sum(rate())` (no subquery) at 1767227550, across the restart |
| `validate-post-instant-rate.sh` | q4 uses `irate()` for POST requests, per instance |
| `validate-error-ratio-per-job.sh` | q5 divides the aggregated 500 rate by the aggregated total rate |
