---
estimated_duration: 20m
---

# Lab: Age And Uptime From Timestamps

Graded lab for the module on `time()`, `timestamp()` and the age of an event. **UNTESTED:** this lab was built without a live run, and only static checks were made. The learner writes five PromQL expressions and stores them in the ConfigMap `answers`. Each grader reads one key, runs the expression and a reference expression at a fixed evaluation time, and compares the series and values.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-070/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-070/module-01/labs/lab-01
astrona destroy ats-049-lab-070-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1-uptime.sh` | `q1` returns `time() - process_start_time_seconds` |
| `validate-q2-backup-age-minutes.sh` | `q2` returns the backup age in minutes, with a division by 60 |
| `validate-q3-overdue-backups.sh` | `q3` filters backups older than 900 seconds and keeps the age |
| `validate-q4-sample-freshness.sh` | `q4` uses `timestamp(up)` and gives 193 at time 1767229393 |
| `validate-q5-recent-restarts-hours.sh` | `q5` gives the uptime in hours for processes younger than 2 hours |
