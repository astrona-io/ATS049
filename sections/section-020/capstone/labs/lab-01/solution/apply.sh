#!/usr/bin/env bash
# Reference solution: stores one PromQL expression per question in the answers ConfigMap.
set -euo pipefail
kubectl -n starfleet create configmap answers \
  --from-literal=q1='(disk_total_bytes - disk_used_bytes) / deriv(disk_used_bytes[15m]) / 3600' \
  --from-literal=q2='sum by (instance) (rate(http_requests_total{job="bridge"}[5m]))' \
  --from-literal=q3='sum by (instance) (resets(http_requests_total[1h]))' \
  --from-literal=q4='deriv(queue_depth{job="shuttle"}[5m]) * 60' \
  --from-literal=q5='sum(increase(http_requests_total{status="500"}[1h])) / sum(increase(http_requests_total[1h]))' \
  --dry-run=client -o yaml | kubectl apply -f -
