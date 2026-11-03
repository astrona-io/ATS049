---
draft: true
exam_objectives:
- Selecting Data
---
# Section 010: Selecting Data

Every PromQL expression starts by selecting series, and every later step (rates, aggregations, comparisons) works on what the selector returned. This section teaches how to select exactly the population you mean and how time decides which samples a selector sees. It comes first because a wrong selection makes every later calculation wrong without any error.

**Curriculum item covered:** Selecting Data (28% PromQL domain of the Prometheus Certified Associate)

---

## What You Will Master

- Explain what a time series is and which parts of it identify it: the metric name and the set of labels
- Write selectors with the four matchers `=`, `!=`, `=~` and `!~`, and predict the result
- Explain that regular expression matchers are fully anchored, and that a matcher for an empty value also selects series without the label
- Explain why a selector needs at least one non-empty matcher, and select by metric name with `__name__`
- Name the four PromQL types, write range selectors with valid durations and count a result with `count` and `count by`
- State how the lookback delta and staleness decide which sample a selector returns, and why a series can be absent
- Move a selector in time with `offset` (also negative) and `@` (with `start()` and `end()`), and combine them
- Explain how a range query evaluates at each step, and the difference between step and window

---

## The Learning Path

### 1. Selectors, Matchers And The Series Model
*   **Module Reader:** **Selectors, Matchers And The Series Model**
*   **Hands-on Playground:** `sections/section-010/module-01/playground` - a kind cluster with a Prometheus server (3.5.5) that holds a fixed, generated dataset of one hour (68 series, no scraping) and a `shuttle` pod with the query helper `/tools/pq.py`.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/module-01/playground
    ```
*   **Module Lab:** Select Exact Populations - `sections/section-010/module-01/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/module-01/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/module-01/labs/lab-01
    ```

### 2. Evaluation Time: Lookback, Staleness, Offset And @
*   **Module Reader:** **Evaluation Time: Lookback, Staleness, Offset And @**
*   **Hands-on Playground:** `sections/section-010/module-02/playground` - the same environment, used for time questions: a target that vanishes, a failure between two steps and a restart.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/module-02/playground
    ```
*   **Module Lab:** Time-Shift Questions - `sections/section-010/module-02/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/module-02/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/module-02/labs/lab-01
    ```

### Section Capstone Challenge
*   **Comprehensive Challenge:** Selecting Data Capstone - `sections/section-010/capstone/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/capstone/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** Five questions that mix matchers, selection by metric name, range selectors, counting, `offset` and `@`. The grader runs each expression at a stated evaluation time and compares the result with a reference.

---

## Ready for Assessment?

The knowledge check `quiz.yaml` of this section follows the capstone.
