---
estimated_duration: 30m
---

# Capstone Lab: Rates and Derivatives

Graded capstone, difficulty advanced. Status: UNTESTED (built without a live run; static checks only). It combines counter functions (rates across a restart, resets, increase over a range that holds a reset) with gauge functions (slope of a growing queue, time until a disk is full). The learner writes five PromQL expressions into the ConfigMap `answers` in `starfleet`; each grader compares the result of the stored expression with a reference at a fixed time.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-049-capstone-020
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-disk-hours-to-full.sh` | q1 divides free space by `deriv()` and converts to hours at 1767228600 |
| `validate-bridge-rate-across-restart.sh` | q2 uses `sum by (instance)` over `rate()` at 1767227550, no subquery |
| `validate-restarts-per-instance.sh` | q3 sums `resets()` per instance |
| `validate-shuttle-queue-growth-per-minute.sh` | q4 uses `deriv()` times 60 on the shuttle queue |
| `validate-hourly-error-share.sh` | q5 divides summed `increase()` values over a range that holds the reset |
