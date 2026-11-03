---
estimated_duration: 30m
---

# Capstone: Timestamp Metrics

Graded capstone for the section on timestamp metrics. **UNTESTED:** this lab was built without a live run, and only static checks were made. The learner writes five PromQL expressions that mix age computations, unit conversion and freshness tests, and stores them in the ConfigMap `answers`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-070/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-070/capstone/labs/lab-01
astrona destroy ats-049-capstone-070
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1-backups-over-30-minutes.sh` | `q1` returns the backup age in minutes for sources older than 30 minutes |
| `validate-q2-backup-series-vanished.sh` | `q2` finds the backup series that vanished with `offset` and `unless` |
| `validate-q3-probe-1-absent-10m.sh` | `q3` uses `absent_over_time()` over 10 minutes |
| `validate-q4-restarts-45m.sh` | `q4` finds the restart with `changes()` over 45 minutes |
| `validate-q5-longest-uptime-days.sh` | `q5` returns the longest uptime in days |
