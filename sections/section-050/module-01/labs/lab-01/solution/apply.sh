#!/usr/bin/env bash
# Reference answers for the arithmetic, comparison and precedence lab.
set -euo pipefail
kubectl -n starfleet create configmap answers \
  --from-literal=q1='disk_used_bytes / disk_total_bytes' \
  --from-literal=q2='disk_used_bytes / disk_total_bytes > 0.42' \
  --from-literal=q3='disk_used_bytes / disk_total_bytes > bool 0.42' \
  --from-literal=q4='temperature_celsius * 9 / 5 + 32' \
  --from-literal=q5='sum(disk_used_bytes / disk_total_bytes > bool 0.42)' \
  --dry-run=client -o yaml | kubectl apply -f -
