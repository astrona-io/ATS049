---
draft: true
exam_objectives:
- Aggregating over time
---
# Section 030: Aggregating Over Time

Rates and aggregations answer questions about one moment. Many real questions are about a period: the highest queue depth in the last hour, the lowest number of healthy targets, or the peak request rate of a job. This section teaches the over_time functions that reduce a window of samples to one value, and the subquery that lets those functions work on a computed expression. It comes after selecting data because every window starts with a selector, and it comes before the sections that build alerts and recording rules, because they need these functions.

**Curriculum item covered:** Aggregating over time (PromQL domain of the Prometheus Certified Associate)

---

## What You Will Master

- Reduce a gauge window with `avg_over_time`, `min_over_time`, `max_over_time`, `sum_over_time` and `count_over_time`, and say what each returns for each series
- Use `quantile_over_time`, `stddev_over_time` and `last_over_time`, and know which over_time functions keep the metric name
- Test for missing data with `present_over_time` and `absent_over_time`, and read the labels of the result
- Choose a window from the scrape interval and from the pattern of the data, and apply the left-open boundary of a range
- Explain why `avg_over_time` of a counter or of a ratio misleads, and name the function to use instead
- Write a subquery `expr[range:step]`, state the default step and list the times at which the inner expression is evaluated
- Combine an over_time function with `sum by` and `rate()` to find the peak, the lowest value or the average of a computed value
- Explain why the maximum of a sum and the sum of maximums differ
- Count the evaluations of a subquery, decide when a recording rule is better, and avoid summing counters before `rate()`

---

## The Learning Path

### 1. The over_time Functions
*   **Module Reader:** **The over_time Functions**
*   **Hands-on Playground:** `sections/section-030/module-01/playground` - a kind cluster with a Prometheus server (3.5.5) that holds a fixed, generated dataset of one hour (no scraping) and a `shuttle` pod with the query helper `/tools/pq.py`.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/module-01/playground
    ```
*   **Module Lab:** Window Questions - `sections/section-030/module-01/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/module-01/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/module-01/labs/lab-01
    ```

### 2. Subqueries And Nested Time Aggregation
*   **Module Reader:** **Subqueries And Nested Time Aggregation**
*   **Hands-on Playground:** `sections/section-030/module-02/playground` - the same environment, used for subqueries: step times, a summed rate, the cost of a subquery and a counter restart.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/module-02/playground
    ```
*   **Module Lab:** Subquery Questions - `sections/section-030/module-02/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/module-02/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/module-02/labs/lab-01
    ```

### Section Capstone Challenge
*   **Comprehensive Challenge:** Aggregating Over Time Capstone - `sections/section-030/capstone/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/capstone/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** Five questions that mix a plain over_time window, `absent_over_time` and three subqueries over sums, rates and `up`. The grader runs each expression at a stated evaluation time and compares the result with a reference.

---

## Ready for Assessment?

The knowledge check `quiz.yaml` of this section follows the capstone.
