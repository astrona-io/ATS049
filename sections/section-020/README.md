---
draft: true
exam_objectives:
- Rates and Derivatives
---
# Section 020: Rates and Derivatives

A counter only grows, and the value of a counter alone says little. This section teaches how to turn counters and gauges into speeds, counts and forecasts: `rate()`, `increase()` and `irate()` for counters, and `delta()`, `deriv()`, `predict_linear()`, `changes()` and `resets()` for gauges and events. It comes after selecting data because every function here runs on a range selector.

**Curriculum item covered:** Rates and Derivatives (PromQL domain of the Prometheus Certified Associate)

---

## What You Will Master

- Explain why a counter is read through `rate()` and what the extrapolation at the edges of the range does
- Size the range of `rate()` against the interval between samples
- Choose between `rate()`, `increase()` and `irate()` and give the unit of each result
- Explain how a counter reset is repaired and why a restart does not give a negative rate
- Aggregate in the correct order with `sum(rate())` and choose between `by` and `without`
- Use `delta()` and `idelta()` for gauges and explain why `rate()` is wrong for them
- Calculate a slope with `deriv()` and a forecast with `predict_linear()`, and compute the time until a disk is full
- Count events with `changes()` and `resets()`
- Choose the correct function for a question from the metric type and the unit wanted

---

## The Learning Path

### 1. Counters, rate And increase
*   **Module Reader:** **Counters, rate And increase**
*   **Hands-on Playground:** `sections/section-020/module-01/playground` - a kind cluster with a Prometheus server (3.5.5) that holds a fixed, generated dataset of one hour (no scraping) and a `shuttle` pod with the query helper `/tools/pq.py`. The counter `http_requests_total` restarts on one instance.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-01/playground
    ```
*   **Module Lab:** Rates And Increases - `sections/section-020/module-01/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-01/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-01/labs/lab-01
    ```

### 2. Gauges: delta, deriv And predict_linear
*   **Module Reader:** **Gauges: delta, deriv And predict_linear**
*   **Hands-on Playground:** `sections/section-020/module-02/playground` - the same environment, used for gauges: queues, disks that fill and temperatures.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-02/playground
    ```
*   **Module Lab:** Derivative Questions - `sections/section-020/module-02/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-02/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-02/labs/lab-01
    ```

### Section Capstone Challenge
*   **Comprehensive Challenge:** Rates and Derivatives Capstone - `sections/section-020/capstone/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/capstone/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** Five questions that mix both modules: the hours until a disk is full, request rates across a restart, restart counts, the growth of a queue per minute and an hourly error share. The grader runs each expression at a stated evaluation time and compares the result with a reference.

---

## Ready for Assessment?

The knowledge check `quiz.yaml` of this section follows the capstone.
