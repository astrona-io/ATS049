#!/usr/bin/env bash
# Reference solution: stores one PromQL expression per question in the answers ConfigMap.
set -euo pipefail
kubectl -n starfleet create configmap answers \
  --from-literal=q1='sum without (method, status) (rate(http_requests_total[5m]))' \
  --from-literal=q2='sum by (instance) (increase(http_requests_total{status="500"}[10m]))' \
  --from-literal=q3='sum(rate(http_requests_total{job="bridge"}[5m]))' \
  --from-literal=q4='sum by (instance) (irate(http_requests_total{job="bridge",method="POST"}[1m]))' \
  --from-literal=q5='sum by (job) (rate(http_requests_total{status="500"}[5m])) / sum by (job) (rate(http_requests_total[5m]))' \
  --dry-run=client -o yaml | kubectl apply -f -
