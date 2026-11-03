# Section 040: Aggregating Over Dimensions

This section teaches how to collapse many series into fewer series with PromQL aggregation operators, and how to control which labels the result keeps. It also covers ranking series, statistics across series, correct averaging and the ways an aggregate can hide a failing instance.

**Curriculum item covered:** Aggregating over dimensions (PromQL, 28% of the Prometheus Certified Associate exam)

---

## What You Will Master

- Use `sum`, `min`, `max`, `avg`, `count` and `group` with `by` and `without`, and predict the labels of the result, including the removal of the metric name
- Write `sum by (...) (rate(...))` and explain why the rate comes before the sum
- Count targets and series with `count`, `count by` and a count of a count, and read the `up` metric
- Select the highest or lowest series with `topk` and `bottomk`, and explain why the result keeps all original labels
- Compute a quantile, a standard deviation and a variance across series, and count values with `count_values`
- Explain why the average of per-instance averages is wrong, and write the weighted form
- Choose an aggregation that shows a failing instance instead of hiding it

---

## The Learning Path

### 1. Aggregation Operators With by And without
*   **Module Reader:** **[Module 1: Aggregation Operators With by And without](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-040/module-01/playground` - kind cluster with Prometheus 3.5.5 and a `shuttle` helper pod in the namespace `starfleet`. Prometheus starts with a fixed dataset of one hour of samples for five targets.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-01/playground
    ```
*   **Hands-on Lab:** `sections/section-040/module-01/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-01/labs/lab-01
    astrona submit -c .
    ```

### 2. topk, bottomk, quantile, count_values And Statistics
*   **Module Reader:** **[Module 2: topk, bottomk, quantile, count_values And Statistics](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-040/module-02/playground` - the same environment and dataset.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-02/playground
    ```
*   **Hands-on Lab:** `sections/section-040/module-02/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-02/labs/lab-01
    astrona submit -c .
    ```

### Section Capstone Challenge
*   **Comprehensive Challenge:** Aggregating Over Dimensions Capstone - `sections/section-040/capstone/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/capstone/labs/lab-01
    astrona submit -c .
    ```
*   **Hands-on Objective:** Answer five questions that mix both modules: a weighted error ratio, a minimum of `up` that shows a failed target, a ranking, a standard deviation and a count of a count.

---

## Status

The playgrounds, labs and graders are built without a live run. They are untested.

## Ready for Assessment?

*   Take the Section 040 knowledge check (`quiz.yaml`).
