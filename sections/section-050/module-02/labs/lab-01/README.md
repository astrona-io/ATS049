---
estimated_duration: 20m
---

# Lab: Vector Matching And Set Operators

UNTESTED: this lab was built without a live run. Static checks only.

Graded lab for vector matching and the set operators. The learner stores five PromQL expressions in the ConfigMap `answers`, and each validation script evaluates the learner's expression and a reference expression at a fixed Unix time and compares the results. The task is in `question.md` and the walkthrough in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/module-02/labs/lab-01
astrona destroy ats-049-lab-050-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-q1.sh` | `ignoring` or `on` pairs the 200 and 500 counters (time 1767229200) |
| `validate-q2.sh` | `group_left` copies `version` from `build_info` (1767229200) |
| `validate-q3.sh` | Many-to-one match copies `team` onto five counters (1767229200) |
| `validate-q4.sh` | `and` with `up == 0` keeps the down target (1767228300) |
| `validate-q5.sh` | `unless` removes the down target (1767228300) |
