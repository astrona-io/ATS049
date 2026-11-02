---
draft: true
exam_objectives:
- Histograms
---
# Summary

Histograms preserve distribution evidence that can be combined under compatible measurement and bucket contracts. Classic buckets are cumulative and retain the le boundary dimension for quantile calculation.

Quantiles are estimates whose accuracy depends on distribution resolution. Client summary quantiles cannot simply be averaged into a fleet percentile, and native histograms use a different sample representation that requires compatible tooling and queries.
