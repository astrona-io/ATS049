---
estimated_duration: 20m
---

# Lab: Means, Fractions And Native Histograms

**Status: UNTESTED.** Built without a live run; only static checks were made (`astrona validate`, `bash -n`, YAML parsing).

Graded lab for means and fractions of a classic histogram. The learner stores four PromQL expressions. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/module-02/labs/lab-01
astrona destroy ats-049-lab-060-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`. Prometheus 3.5.5 loads the dataset when the cluster starts; allow a short wait for `deploy/prometheus`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1-mean-per-instance.sh` | q1 returns the mean duration per instance over 5 minutes |
| `validate-q2-mean-overall.sh` | q2 returns the mean duration of all instances together |
| `validate-q3-share-under-025.sh` | q3 returns the share of requests at or under 0.25 seconds per instance |
| `validate-q4-share-over-1s.sh` | q4 returns the share of requests slower than 1 second for the whole service |

Each script reads one key of the ConfigMap `answers`, evaluates the learner's expression and a reference expression at a fixed time, and compares the result type, the label sets and the values.
