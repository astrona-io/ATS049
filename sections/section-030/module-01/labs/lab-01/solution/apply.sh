#!/usr/bin/env bash
# Reference solution: stores one PromQL expression per question in the answers ConfigMap.
set -euo pipefail
kubectl -n starfleet create configmap answers \
  --from-literal=q1='min_over_time(queue_depth[10m])' \
  --from-literal=q2='quantile_over_time(0.9, temperature_celsius[10m])' \
  --from-literal=q3='stddev_over_time(queue_depth{job="bridge"}[5m])' \
  --from-literal=q4='last_over_time(temperature_celsius[15m])' \
  --dry-run=client -o yaml | kubectl apply -f -
