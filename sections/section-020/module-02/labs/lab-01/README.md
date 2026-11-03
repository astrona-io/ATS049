---
estimated_duration: 25m
---

# Lab: Gauges: delta, deriv And predict_linear

Graded lab. Status: UNTESTED (built without a live run; static checks only). The learner writes six PromQL expressions into the ConfigMap `answers` in `starfleet`. Each grader runs the stored expression and a reference expression against Prometheus at a fixed time and compares labels and values. The task is in `question.md` and the walkthrough in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-049-lab-020-02
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-queue-change-5m.sh` | q1 uses `delta()` (not `rate()`) on `queue_depth` |
| `validate-disk-seconds-to-full.sh` | q2 uses `deriv()` and divides free space by the slope at 1767228600 |
| `validate-temperature-in-30-minutes.sh` | q3 uses `predict_linear()` with 1800 seconds at 1767228600 |
| `validate-disks-full-within-a-day.sh` | q4 compares a 24 hour prediction with `disk_total_bytes` at 1767228600 |
| `validate-counters-that-reset.sh` | q5 uses `resets()` and keeps series above 0 |
| `validate-queue-changes-10m.sh` | q6 uses `changes()` over 10 minutes |
