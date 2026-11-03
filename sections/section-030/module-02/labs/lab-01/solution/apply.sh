#!/usr/bin/env bash
# Reference solution: stores one PromQL expression per question in the answers ConfigMap.
set -euo pipefail
kubectl -n starfleet create configmap answers \
  --from-literal=q1='max_over_time(sum by (job) (queue_depth)[5m:1m])' \
  --from-literal=q2='max_over_time(sum by (job) (rate(http_requests_total[1m]))[10m:1m])' \
  --from-literal=q3='min_over_time(min by (job) (up)[20m:15s])' \
  --from-literal=q4='avg_over_time(sum by (job) (queue_depth)[30m:1m])' \
  --dry-run=client -o yaml | kubectl apply -f -
