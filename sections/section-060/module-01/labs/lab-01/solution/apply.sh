#!/usr/bin/env bash
# Reference solution: writes the reference expression of every question into the
# ConfigMap answers. This is what `astrona test` applies.
set -euo pipefail

kubectl -n starfleet create configmap answers \
  --from-literal=q1='histogram_quantile(0.9, sum by (instance, le) (rate(http_request_duration_seconds_bucket[5m])))' \
  --from-literal=q2='histogram_quantile(0.9, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))' \
  --from-literal=q3='histogram_quantile(0.9, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))' \
  --from-literal=q4='http_request_duration_seconds_bucket{instance="bridge-0:8080",le="0.5"} - ignoring(le) http_request_duration_seconds_bucket{instance="bridge-0:8080",le="0.25"}' \
  --dry-run=client -o yaml | kubectl apply -f -
