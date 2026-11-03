---
estimated_duration: 30m
---

# Capstone: Binary Operators

UNTESTED: this lab was built without a live run. Static checks only.

Graded capstone that mixes arithmetic, comparison, precedence, vector matching, `group_left` and the set operators. The learner stores five PromQL expressions in the ConfigMap `answers`, and each validation script evaluates the learner's expression and a reference expression at a fixed Unix time and compares the results. The task is in `question.md` and the walkthrough in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/capstone/labs/lab-01
astrona destroy ats-049-capstone-050
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1.sh` | Error ratio per job with `rate` and `sum by (job)` (1767229200) |
| `validate-q2.sh` | Ratio divided by `error_budget_ratio` with `on(job)` (1767229200) |
| `validate-q3.sh` | Age filter plus `and on(instance) up == 1` (1767229200) |
| `validate-q4.sh` | Filter, then two `group_left` matches (1767229200) |
| `validate-q5.sh` | `count(up == 0)` at 1767228300 |
