#!/usr/bin/env bash
# Reference answers: one expression per question in the ConfigMap `answers`.
set -euo pipefail
kubectl -n starfleet create configmap answers \
  --from-literal=q1='count by (instance) ({__name__=~"http_.*", status=~"5.."})' \
  --from-literal=q2='up{job="probe"} offset 10m' \
  --from-literal=q3='queue_depth{job="bridge", instance!="bridge-0:8080"}[5m] @ 1767227400' \
  --from-literal=q4='count by (job) (up offset -10m)' \
  --from-literal=q5='{__name__=~"up|build_info", instance="shuttle-0:8080"}' \
  --dry-run=client -o yaml | kubectl apply -f -
