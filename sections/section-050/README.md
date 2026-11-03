---
draft: true
exam_objectives:
- Binary operators
---
# Section 050: Binary Operators

Binary operators combine two values into one result, and they carry most real PromQL: ratios, thresholds, joins with information metrics and set logic on series. This section teaches the arithmetic, comparison and set operators, the order in which they run, and how Prometheus decides which series on the left belongs with which series on the right. It comes after selecting data, aggregation and functions because every example combines the results of those steps.

**Curriculum item covered:** Binary operators (28% PromQL domain of the Prometheus Certified Associate)

---

## What You Will Master

- Apply `+`, `-`, `*`, `/`, `%`, `^` and `atan2` between a scalar and an instant vector, and say which labels the result keeps
- Use a comparison operator as a filter, and use `bool` to return 0 or 1 instead
- Explain why a comparison between two scalars needs `bool`
- Predict the evaluation order from the precedence table, including the right-associative `^`
- Write the error ratio and explain why both sides are aggregated with the same `by`
- Say what division by zero returns and remove NaN values with a comparison
- Match two vectors one to one with `on` and `ignoring`, and read the error for a match key that is not unique
- Use `group_left` and `group_right` to match many series with one, and copy `version` and `team` from information metrics
- Use `and`, `or` and `unless` to keep, add or remove series by their labels

---

## The Learning Path

### 1. Arithmetic, Comparison And Precedence
*   **Module Reader:** **Arithmetic, Comparison And Precedence**
*   **Hands-on Playground:** `sections/section-050/module-01/playground` - a kind cluster with a Prometheus server (3.5.5) that holds a fixed, generated dataset of one hour (68 series, no scraping) and a `shuttle` pod with the query helper `/tools/pq.py`.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/module-01/playground
    ```
*   **Module Lab:** Arithmetic, Comparison And Precedence - `sections/section-050/module-01/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/module-01/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/module-01/labs/lab-01
    ```

### 2. Vector Matching And Set Operators
*   **Module Reader:** **Vector Matching And Set Operators**
*   **Hands-on Playground:** `sections/section-050/module-02/playground` - the same environment, used for matching questions: request counters per status, the information metrics `build_info` and `team_info`, and targets that go down.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/module-02/playground
    ```
*   **Module Lab:** Vector Matching And Set Operators - `sections/section-050/module-02/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/module-02/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/module-02/labs/lab-01
    ```

### Section Capstone Challenge
*   **Comprehensive Challenge:** Binary Operators Capstone - `sections/section-050/capstone/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/capstone/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** Five questions that mix a ratio, a division by an information metric, a set operator, two chained `group_left` matches and a count at a stated time. The grader runs each expression at a fixed evaluation time and compares the result with a reference.

---

## Ready for Assessment?

The knowledge check `quiz.yaml` of this section follows the capstone.
