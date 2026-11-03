#!/usr/bin/env bash
# Reference answers for the vector matching and set operators lab.
set -euo pipefail
kubectl -n starfleet create configmap answers \
  --from-literal=q1='http_requests_total{status="200"} + ignoring(status) http_requests_total{status="500"}' \
  --from-literal=q2='queue_depth * on(instance) group_left(version) build_info' \
  --from-literal=q3='http_requests_total{status="500"} * on(instance) group_left(team) team_info' \
  --from-literal=q4='queue_depth and on(instance) up == 0' \
  --from-literal=q5='queue_depth unless on(instance) up == 0' \
  --dry-run=client -o yaml | kubectl apply -f -
