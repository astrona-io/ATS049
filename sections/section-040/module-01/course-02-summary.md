---
draft: true
exam_objectives:
- Aggregating over dimensions
---
# Summary

Cross-series aggregation combines a selected population at an evaluation time and defines which labels survive. By keeps named dimensions, while without removes named dimensions and preserves the others.

The calculation must respect units, counter resets and denominator weights. A global error ratio usually comes from summed failures divided by summed requests, while averaging per-instance percentages can misrepresent fleets with unequal traffic.
