---
estimated_duration: 20m
---

# Lab: The over_time Functions

Graded lab. Status: UNTESTED (built without a live run; static checks only). The learner writes four PromQL expressions into the ConfigMap `answers` in `starfleet`. Each grader runs the stored expression and a reference expression against Prometheus at a fixed time and compares labels and values. The task is in `question.md` and the walkthrough in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/module-01/labs/lab-01
astrona destroy ats-049-lab-030-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-lowest-queue-depth.sh` | q1 uses `min_over_time` with a 10 minute range on `queue_depth` |
| `validate-temperature-p90.sh` | q2 uses `quantile_over_time` with 0.9 on `temperature_celsius` over 10 minutes |
| `validate-bridge-queue-spread.sh` | q3 uses `stddev_over_time` on the `bridge` queue depth over 5 minutes |
| `validate-last-temperature.sh` | q4 uses `last_over_time` over 15 minutes and returns both probes with the metric name |
