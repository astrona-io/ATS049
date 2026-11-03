---
estimated_duration: 20m
---

# Lab: Arithmetic, Comparison And Precedence

UNTESTED: this lab was built without a live run. Static checks only.

Graded lab for arithmetic, comparison and precedence. The learner stores five PromQL expressions in the ConfigMap `answers`, and each validation script evaluates the learner's expression and a reference expression at Unix time 1767228600 and compares the results. The task is in `question.md` and the walkthrough in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/module-01/labs/lab-01
astrona destroy ats-049-lab-050-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1.sh` | Used fraction of each disk, no `bool` |
| `validate-q2.sh` | Fraction filtered with `> 0.42` |
| `validate-q3.sh` | `bool` flags for both disks |
| `validate-q4.sh` | Fahrenheit conversion, precedence of `*`, `/` and `+` |
| `validate-q5.sh` | `sum` over a `bool` comparison, one series without labels |
