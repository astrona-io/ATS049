#!/usr/bin/env bash
# Reference answers: one expression per question in the ConfigMap `answers`.
set -euo pipefail
kubectl -n starfleet create configmap answers \
  --from-literal=q1='up{job=~"bridge|shuttle"}' \
  --from-literal=q2='http_requests_total{status="500", instance!="shuttle-0:8080"}' \
  --from-literal=q3='{__name__=~"disk_.*"}' \
  --from-literal=q4='count by (job) (http_requests_total)' \
  --from-literal=q5='http_requests_total{job="shuttle", status="200"}[30s]' \
  --dry-run=client -o yaml | kubectl apply -f -
