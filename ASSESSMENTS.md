# Reusable Question Banks

Each section has one bank, `sections/section-0N0/quiz.yaml`, and the course has a
final domain bank, `sections/final-domain-quiz.yaml`. Each bank uses schema version 1
and the contract in `schemas/question-bank.schema.json`. The banks are registered in
`astrona.yaml` as `type: quiz` items with `pass_score: 70`: a section bank after its
capstone lab, and the final bank at the end of the course.

A section bank has 12 original single-choice questions with three options. The final
bank has 15 questions drawn from all seven sections. The correct option is spread
evenly over a, b and c in every bank. All banks remain draft for review.

## Fields And Rendering

- `id`: stable bank or question identity; preserve it when editing wording.
- `scope`: section or domain checkpoint.
- `placement`: relative reading path after which the checkpoint belongs.
- `learning_objective`: the measurable outcome checked by the question.
- `source_readings`: author traceability to the teaching; not learner navigation.
- `prompt`: learner-visible question text.
- `options`: stable option IDs, answer text and per-option feedback.
- `correct_option`: the ID of the single correct option.
- `explanation`: feedback reinforcing the supported answer.

The application should send only the question ID, prompt and option IDs/text to
the learner before submission. Keep `correct_option`, `explanation` and option
explanations on the server until feedback is permitted. Match answers by option
ID, not display position, so a later renderer can shuffle choices safely.

The banks contain answer keys and are public learning material, so this is not
a secure examination bank. Do not treat scores as an official PCA result.

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
