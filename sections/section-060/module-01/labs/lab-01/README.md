---
estimated_duration: 20m
---

# Lab: Classic Histograms And histogram_quantile

**Status: UNTESTED.** Built without a live run; only static checks were made (`astrona validate`, `bash -n`, YAML parsing).

Graded lab for classic histograms. The Prometheus server holds the histogram http_request_duration_seconds for the two bridge instances. The learner stores four PromQL expressions. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/module-01/labs/lab-01
astrona destroy ats-049-lab-060-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`. Prometheus 3.5.5 loads the dataset when the cluster starts; allow a short wait for `deploy/prometheus`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1-p90-per-instance.sh` | q1 returns the 0.9 quantile per instance from 5 minute bucket rates |
| `validate-q2-p90-fleet.sh` | q2 returns the 0.9 quantile of all instances together |
| `validate-q3-p90-fleet-across-reset.sh` | q3 returns the fleet 0.9 quantile at the time of the bridge-1 reset window |
| `validate-q4-observations-between-bounds.sh` | q4 returns the observations of bridge-0 between 0.25 and 0.5 seconds |

Each script reads one key of the ConfigMap `answers`, evaluates the learner's expression and a reference expression at a fixed time, and compares the result type, the label sets and the values.
