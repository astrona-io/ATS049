#!/usr/bin/env bash
# Reference solution: stores one PromQL expression per question in the answers ConfigMap.
set -euo pipefail
kubectl -n starfleet create configmap answers \
  --from-literal=q1='delta(queue_depth[5m])' \
  --from-literal=q2='(disk_total_bytes - disk_used_bytes) / deriv(disk_used_bytes[15m])' \
  --from-literal=q3='predict_linear(temperature_celsius[10m], 1800)' \
  --from-literal=q4='predict_linear(disk_used_bytes[1h], 24 * 3600) > disk_total_bytes' \
  --from-literal=q5='resets(http_requests_total[1h]) > 0' \
  --from-literal=q6='changes(queue_depth[10m])' \
  --dry-run=client -o yaml | kubectl apply -f -
