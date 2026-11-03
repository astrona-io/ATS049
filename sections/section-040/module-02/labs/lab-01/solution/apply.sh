#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl -n starfleet create configmap answers \
  --from-literal=q1='topk(2, sum by (instance) (rate(http_requests_total[5m])))' \
  --from-literal=q2='bottomk by (job) (1, queue_depth)' \
  --from-literal=q3='quantile(0.5, queue_depth)' \
  --from-literal=q4='count_values("state", up)' \
  --from-literal=q5='sum(rate(http_requests_total{job="bridge", status="500"}[5m])) / sum(rate(http_requests_total{job="bridge"}[5m]))' \
  --from-literal=q6='sum(rate(http_request_duration_seconds_sum[5m])) / sum(rate(http_request_duration_seconds_count[5m]))' \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
