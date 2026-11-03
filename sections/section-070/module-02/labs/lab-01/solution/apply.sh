#!/usr/bin/env bash
# Reference answers for the lab. `astrona test` runs this to prove the checks pass.
set -euo pipefail

kubectl -n starfleet create configmap answers \
  --from-literal=q1='up == 0' \
  --from-literal=q2='absent(up{instance="probe-1:9100"})' \
  --from-literal=q3='changes(process_start_time_seconds[1h]) > 0' \
  --from-literal=q4='time() - timestamp(up) > 60' \
  --from-literal=q5='up offset 10m unless up' \
  --dry-run=client -o yaml | kubectl apply -f -
