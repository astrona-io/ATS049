---
estimated_duration: 20m
---

# Lab: Histograms Capstone

**Status: UNTESTED.** Built without a live run; only static checks were made (`astrona validate`, `bash -n`, YAML parsing).

Capstone for the histograms section (advanced). It combines quantiles, aggregation across instances, the counter reset, means and shares. The learner stores five PromQL expressions. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/capstone/labs/lab-01
astrona destroy ats-049-capstone-060
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`. Prometheus 3.5.5 loads the dataset when the cluster starts; allow a short wait for `deploy/prometheus`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1-p90-per-instance.sh` | q1 returns the 0.9 quantile per instance |
| `validate-q2-instances-over-limit.sh` | q2 returns only the instances whose 0.9 quantile is above 0.4 seconds |
| `validate-q3-mean-overall.sh` | q3 returns the mean duration of the whole service |
| `validate-q4-share-under-025.sh` | q4 returns the share of requests at or under 0.25 seconds for the whole service |
| `validate-q5-p90-fleet-across-reset.sh` | q5 returns the fleet 0.9 quantile in the window that contains the bridge-1 restart |

Each script reads one key of the ConfigMap `answers`, evaluates the learner's expression and a reference expression at a fixed time, and compares the result type, the label sets and the values.
