---
estimated_duration: 20m
---

# Lab: Absence And Freshness

Graded lab for the module on `up`, `absent()`, restarts, stale series and gaps. **UNTESTED:** this lab was built without a live run, and only static checks were made. The learner writes five PromQL expressions and stores them in the ConfigMap `answers`. Each grader reads one key, runs the expression and a reference expression at a fixed evaluation time, and compares the series and values.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-070/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-070/module-02/labs/lab-01
astrona destroy ats-049-lab-070-02
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1-failing-targets.sh` | `q1` returns `up == 0` at time 1767228300 |
| `validate-q2-missing-probe.sh` | `q2` uses `absent()` and returns the label `instance` only |
| `validate-q3-restarts.sh` | `q3` uses `changes()` on the start time and filters above 0 |
| `validate-q4-stale-series.sh` | `q4` finds `probe-1` with age 290 at time 1767228890 |
| `validate-q5-vanished-series.sh` | `q5` uses `offset` and `unless` and returns `probe-1` |
