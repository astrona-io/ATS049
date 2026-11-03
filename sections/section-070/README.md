---
draft: true
exam_objectives:
- Timestamp Metrics
---
# Section 070: Timestamp Metrics

This section teaches how PromQL works with time: the evaluation time returned by `time()`, the stored time of a sample returned by `timestamp()`, metrics whose value is a Unix time, and the tests that find series that are down, missing, stale or restarted. It matters for the exam because overdue-work and freshness alerts depend on these functions, and because an empty result can hide a failure.

**Curriculum item covered:** Timestamp Metrics

---

## What You Will Master

- Explain that `time()` returns the evaluation time and `timestamp(v)` returns the stored time of a sample
- Compute the uptime of a process and the age of the last successful backup with `time() - metric`
- Convert an age from seconds to minutes, hours or days and compare it with a threshold
- Write an overdue-work expression that returns only the series over the limit
- Tell `up == 0` from a missing series and test for absence with `absent()` and `absent_over_time()`
- Predict the labels of the series that `absent()` returns
- Detect restarts with `changes()`, stale series with `timestamp()`, and vanished series with `offset` and `unless`

---

## The Learning Path

### 1. time, timestamp And Age Of An Event
*   **Module Reader:** **[Module 1: time, timestamp And Age Of An Event](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-070/module-01/playground`: a kind cluster with Prometheus 3.5.5, a fixed one-hour dataset, and a `shuttle` pod with the query helper.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-070/module-01/playground
    ```
*   **Graded Lab:** `sections/section-070/module-01/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-070/module-01/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-070/module-01/labs/lab-01
    ```

### 2. Freshness, Absence And Gaps
*   **Module Reader:** **[Module 2: Freshness, Absence And Gaps](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-070/module-02/playground`: the same environment, used to test `up`, `absent()`, `changes()` and stale series.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-070/module-02/playground
    ```
*   **Graded Lab:** `sections/section-070/module-02/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-070/module-02/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-070/module-02/labs/lab-01
    ```

### Section Capstone Challenge
*   **Comprehensive Challenge:** Timestamp Metrics Capstone: `sections/section-070/capstone/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-070/capstone/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-070/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** Write five expressions that mix age computation with freshness tests: backup ages in minutes, a vanished backup series, an absence test over 10 minutes, restarts in 45 minutes and the longest uptime in days.

---

## Ready for Assessment?

*   **Knowledge check:** `sections/section-070/quiz.yaml` has 12 single-choice questions that follow the capstone.
