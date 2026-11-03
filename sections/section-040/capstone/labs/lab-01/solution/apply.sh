#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl -n starfleet create configmap answers \
  --from-literal=q1='sum by (job) (rate(http_requests_total{status="500"}[5m])) / sum by (job) (rate(http_requests_total[5m]))' \
  --from-literal=q2='min by (job) (up)' \
  --from-literal=q3='topk(1, sum by (instance) (rate(http_requests_total[5m])))' \
  --from-literal=q4='stddev by (job) (queue_depth)' \
  --from-literal=q5='count by (instance) (count by (instance, cpu) (node_cpu_seconds_total))' \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
