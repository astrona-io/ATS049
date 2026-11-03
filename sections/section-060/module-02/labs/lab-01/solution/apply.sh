#!/usr/bin/env bash
# Reference solution: writes the reference expression of every question into the
# ConfigMap answers. This is what `astrona test` applies.
set -euo pipefail

kubectl -n starfleet create configmap answers \
  --from-literal=q1='sum by (instance) (rate(http_request_duration_seconds_sum[5m])) / sum by (instance) (rate(http_request_duration_seconds_count[5m]))' \
  --from-literal=q2='sum(rate(http_request_duration_seconds_sum[5m])) / sum(rate(http_request_duration_seconds_count[5m]))' \
  --from-literal=q3='sum by (instance) (rate(http_request_duration_seconds_bucket{le="0.25"}[5m])) / sum by (instance) (rate(http_request_duration_seconds_count[5m]))' \
  --from-literal=q4='1 - sum(rate(http_request_duration_seconds_bucket{le="1"}[5m])) / sum(rate(http_request_duration_seconds_count[5m]))' \
  --dry-run=client -o yaml | kubectl apply -f -
