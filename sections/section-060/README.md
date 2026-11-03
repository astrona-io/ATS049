<!-- astrona:generated section-readme -->
# Section 060: Histograms

Makes the reader able to turn the buckets, the sum and the count of a classic histogram into quantiles, means and shares of requests, and to explain how summaries and native histograms differ. It matters because latency objectives are written as percentiles and as shares, and a wrong aggregation gives a believable but wrong number.

**Curriculum item covered:** Histograms (PromQL, 28% of the Prometheus Certified Associate exam)

---

## What You Will Master

- Describe the `_bucket`, `_sum` and `_count` series of a classic histogram and explain why buckets are cumulative
- Subtract neighbouring buckets to count the observations in one range
- Write `histogram_quantile(0.9, sum by (le) (rate(...[5m])))` and say why `rate` comes first and `le` must stay
- Estimate the interpolated value by hand and state how far it can be from the true quantile
- Add bucket rates across instances instead of averaging quantiles
- Explain what a counter reset does to raw buckets and why `rate` still gives a correct quantile
- Compute the mean duration as `rate(_sum) / rate(_count)`, per instance and for the whole service
- Compute the share of requests at or under a bucket bound, and above it, with `ignoring(le)`
- Compare histograms, summaries and native histograms for aggregation, accuracy and cost

---

## The Learning Path

### 1. Classic Histograms And histogram_quantile
*   **Module Reader:** **[Classic Histograms And histogram_quantile](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-060/module-01/playground` - kind cluster with Prometheus 3.5.5 and a generated one-hour dataset (no scraping), plus a `shuttle` pod with a query helper. It holds the histogram `http_request_duration_seconds` for the instances `bridge-0:8080` and `bridge-1:8080`; `bridge-1` restarts at Unix time 1767227400.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/module-01/playground
    ```
*   **Graded lab:** `sections/section-060/module-01/labs/lab-01` (untested)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/module-01/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/module-01/labs/lab-01
    ```

### 2. Means, Fractions And Native Histograms
*   **Module Reader:** **[Means, Fractions And Native Histograms](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-060/module-02/playground` - the same environment and dataset. The last lesson of this module is conceptual because the dataset has no native histograms.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/module-02/playground
    ```
*   **Graded lab:** `sections/section-060/module-02/labs/lab-01` (untested)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/module-02/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/module-02/labs/lab-01
    ```

### Section Capstone Challenge
*   **Comprehensive Challenge:** Histograms Capstone - `sections/section-060/capstone/labs/lab-01` (untested)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/capstone/labs/lab-01
    astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/capstone/labs/lab-01
    ```
*   **Hands-on Objective:** Write five expressions for the `/orders` histogram: the 0.9 quantile per instance, the instances above a limit, the mean of the whole service, the share of fast requests, and the fleet quantile in a window that contains the restart of `bridge-1`.

---

## Ready for Assessment?

*   **Knowledge check:** `sections/section-060/quiz.yaml` (12 single-choice questions)
