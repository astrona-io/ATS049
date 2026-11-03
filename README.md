# PromQL (ATS049)

Prometheus Certified Associate (PCA): PromQL, worth 28% of the official curriculum. This course belongs to ATP010.

The course has seven sections, one for each competency of the domain. Each section has two modules. A module has a short landing page, three deep-dive parts, a summary, a private playground and a graded lab. Each section closes with a capstone lab and a knowledge check, and the course ends with a final domain knowledge check of 15 questions. Technical content remains draft.

## Course Outline

| Section | Module | Title |
| --- | --- | --- |
| 010 Selecting Data | 1 | Selectors, Matchers And The Series Model |
| 010 Selecting Data | 2 | Evaluation Time: Lookback, Staleness, Offset And @ |
| 020 Rates and Derivatives | 1 | Counters, rate And increase |
| 020 Rates and Derivatives | 2 | Gauges: delta, deriv And predict_linear |
| 030 Aggregating Over Time | 1 | The over_time Functions |
| 030 Aggregating Over Time | 2 | Subqueries And Nested Time Aggregation |
| 040 Aggregating Over Dimensions | 1 | Aggregation Operators With by And without |
| 040 Aggregating Over Dimensions | 2 | topk, bottomk, quantile, count_values And Statistics |
| 050 Binary Operators | 1 | Arithmetic, Comparison And Precedence |
| 050 Binary Operators | 2 | Vector Matching And Set Operators |
| 060 Histograms | 1 | Classic Histograms And histogram_quantile |
| 060 Histograms | 2 | Means, Fractions And Native Histograms |
| 070 Timestamp Metrics | 1 | time, timestamp And Age Of An Event |
| 070 Timestamp Metrics | 2 | Freshness, Absence And Gaps |

## Author Review

See [curriculum coverage](CURRICULUM.md), [primary sources](SOURCES.md), [question-bank documentation](ASSESSMENTS.md) and [contribution instructions](CONTRIBUTING.md). No runtime execution is claimed.

## Hands-On Coverage

This course has 14 ungraded playgrounds, 14 module labs and 7 capstone labs, each graded against a Prometheus server loaded with a fixed generated dataset. Every playground and lab was built without a live run: it passed `astrona validate -c`, `bash -n` and a YAML parse, and nothing was booted or tested. Each lab README is marked UNTESTED. Live execution remains pending.

| Section | Level | Lab | Difficulty |
| --- | --- | --- | --- |
| 010 | module 1 | Select Exact Populations Lab | intermediate |
| 010 | module 2 | Time-Shift Questions Lab | intermediate |
| 010 | capstone | Selecting Data Capstone | advanced |
| 020 | module 1 | Rates And Increases Lab | intermediate |
| 020 | module 2 | Derivative Questions Lab | intermediate |
| 020 | capstone | Rates and Derivatives Capstone | advanced |
| 030 | module 1 | Window Questions Lab | intermediate |
| 030 | module 2 | Subquery Questions Lab | intermediate |
| 030 | capstone | Aggregating Over Time Capstone | advanced |
| 040 | module 1 | Aggregation Operators With by And without Lab | intermediate |
| 040 | module 2 | Ranking And Statistics Lab | intermediate |
| 040 | capstone | Aggregating Over Dimensions Capstone | advanced |
| 050 | module 1 | Arithmetic, Comparison And Precedence Lab | intermediate |
| 050 | module 2 | Vector Matching And Set Operators Lab | intermediate |
| 050 | capstone | Binary Operators Capstone | advanced |
| 060 | module 1 | Classic Histograms And histogram_quantile Lab | intermediate |
| 060 | module 2 | Means, Fractions And Native Histograms Lab | intermediate |
| 060 | capstone | Histograms Capstone | advanced |
| 070 | module 1 | Age And Uptime From Timestamps Lab | intermediate |
| 070 | module 2 | Absence And Freshness Lab | intermediate |
| 070 | capstone | Timestamp Metrics Capstone | advanced |

