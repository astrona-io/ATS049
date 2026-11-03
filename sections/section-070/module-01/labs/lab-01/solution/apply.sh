#!/usr/bin/env bash
# Reference answers for the lab. `astrona test` runs this to prove the checks pass.
set -euo pipefail

kubectl -n starfleet create configmap answers \
  --from-literal=q1='time() - process_start_time_seconds' \
  --from-literal=q2='(time() - backup_last_success_timestamp_seconds) / 60' \
  --from-literal=q3='time() - backup_last_success_timestamp_seconds > 900' \
  --from-literal=q4='time() - timestamp(up)' \
  --from-literal=q5='(time() - process_start_time_seconds) / 3600 < 2' \
  --dry-run=client -o yaml | kubectl apply -f -
