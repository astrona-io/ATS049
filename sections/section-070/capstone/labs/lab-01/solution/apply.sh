#!/usr/bin/env bash
# Reference answers for the capstone. `astrona test` runs this to prove the checks pass.
set -euo pipefail

kubectl -n starfleet create configmap answers \
  --from-literal=q1='(time() - backup_last_success_timestamp_seconds) / 60 > 30' \
  --from-literal=q2='backup_last_success_timestamp_seconds offset 10m unless backup_last_success_timestamp_seconds' \
  --from-literal=q3='absent_over_time(up{instance="probe-1:9100"}[10m])' \
  --from-literal=q4='changes(process_start_time_seconds[45m]) > 0' \
  --from-literal=q5='max(time() - process_start_time_seconds) / 86400' \
  --dry-run=client -o yaml | kubectl apply -f -
