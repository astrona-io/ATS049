---
draft: true
exam_objectives:
- Rates and Derivatives
---
# Summary

Counter functions account for visible resets and express activity over a selected window. Rate gives a per-second estimate, increase expresses estimated growth across the window, and irate uses the latest pair for a more volatile view.

Apply rate before combining independent counters so resets remain visible. Gauge changes require different functions, and extrapolation or missing samples limit how literally a calculated increase can be interpreted.
