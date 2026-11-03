#!/usr/bin/env bash
# Reference answers: one expression per question in the ConfigMap `answers`.
set -euo pipefail
kubectl -n starfleet create configmap answers \
  --from-literal=q1='queue_depth offset 10m' \
  --from-literal=q2='queue_depth @ 1767227385' \
  --from-literal=q3='queue_depth{job="shuttle"} - queue_depth{job="shuttle"} @ start()' \
  --from-literal=q4='queue_depth{job="shuttle"} offset -10m' \
  --from-literal=q5='up{instance="probe-1:9100"} @ 1767228900 offset 5m' \
  --dry-run=client -o yaml | kubectl apply -f -
