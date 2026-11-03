#!/usr/bin/env bash
# Reference answers for the binary operators capstone.
set -euo pipefail
kubectl -n starfleet create configmap answers \
  --from-literal=q1='sum by (job) (rate(http_requests_total{status="500"}[5m])) / sum by (job) (rate(http_requests_total[5m]))' \
  --from-literal=q2='sum by (job) (rate(http_requests_total{status="500"}[5m])) / sum by (job) (rate(http_requests_total[5m])) / on(job) error_budget_ratio' \
  --from-literal=q3='time() - backup_last_success_timestamp_seconds > 1800 and on(instance) up == 1' \
  --from-literal=q4='(queue_depth > 26) * on(instance) group_left(version) build_info * on(instance) group_left(team) team_info' \
  --from-literal=q5='count(up == 0)' \
  --dry-run=client -o yaml | kubectl apply -f -
