#!/usr/bin/env bash
# Reference solution: stores one PromQL expression per question in the answers ConfigMap.
set -euo pipefail
kubectl -n starfleet create configmap answers \
  --from-literal=q1='max_over_time(disk_used_bytes[30m])' \
  --from-literal=q2='absent_over_time(up{job="probe",instance="probe-1:9100"}[10m])' \
  --from-literal=q3='stddev_over_time(sum by (job) (queue_depth)[30m:1m])' \
  --from-literal=q4='max_over_time(sum by (job) (rate(http_requests_total{status="500"}[1m]))[30m:1m])' \
  --from-literal=q5='min_over_time(sum by (job) (up)[30m:1m])' \
  --dry-run=client -o yaml | kubectl apply -f -
