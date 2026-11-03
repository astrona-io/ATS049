#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl -n starfleet create configmap answers \
  --from-literal=q1='sum by (job) (rate(http_requests_total[5m]))' \
  --from-literal=q2='sum by (instance, mode) (rate(node_cpu_seconds_total[5m]))' \
  --from-literal=q3='count by (__name__) ({job="bridge"})' \
  --from-literal=q4='count by (job) (up == 0)' \
  --from-literal=q5='sum without (instance) (rate(http_requests_total[5m]))' \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
