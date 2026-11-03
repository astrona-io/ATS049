#!/usr/bin/env bash
# Series count per metric name for job bridge
# Reads the learner's expression from ConfigMap answers, key q3, evaluates it and
# a reference expression at the same fixed time, and compares the two results.
set -uo pipefail

export KEY='q3'
export REF='count by (__name__) ({job="bridge"})'
export EVAL_TIME='1767229200'
export RANGE_ARGS=''
export REQUIRE_JSON='["__name__", "count"]'
export FORBID_JSON='[]'
export ALLOW_EMPTY='no'

answer="$(kubectl -n starfleet get configmap answers -o "jsonpath={.data.${KEY}}" 2>/dev/null)"
if [ -z "$answer" ]; then
  echo "FAIL: ConfigMap answers in namespace starfleet has no key ${KEY}"
  exit 1
fi
export ANSWER="$answer"

python3 - <<'PY'
import json
import math
import os
import re
import subprocess
import sys

answer = os.environ["ANSWER"].strip()
reference = os.environ["REF"]
eval_time = os.environ["EVAL_TIME"]
range_args = os.environ["RANGE_ARGS"].split()
allow_empty = os.environ["ALLOW_EMPTY"] == "yes"


def query(expression):
    command = ["kubectl", "-n", "starfleet", "exec", "deploy/shuttle", "--",
               "python", "/tools/pq.py", "--json", expression]
    command += ["--range"] + range_args if range_args else ["--time", eval_time]
    run = subprocess.run(command, capture_output=True, text=True, timeout=60)
    try:
        return json.loads(run.stdout.strip().splitlines()[-1])
    except (ValueError, IndexError):
        print("FAIL: could not query Prometheus: " + (run.stderr.strip() or run.stdout.strip()))
        sys.exit(1)


def number(text):
    return float(text)


def normalise(response):
    data = response["data"]
    kind = data["resultType"]
    result = data["result"]
    if kind in ("scalar", "string"):
        return kind, {(): [number(result[1])] if kind == "scalar" else [result[1]]}
    series = {}
    for item in result:
        key = tuple(sorted(item["metric"].items()))
        if kind == "vector":
            series[key] = [number(item["value"][1])]
        else:
            series[key] = [number(value) for _, value in item["values"]]
    return kind, series


def same(left, right):
    if isinstance(left, str) or isinstance(right, str):
        return left == right
    if math.isnan(left) and math.isnan(right):
        return True
    return math.isclose(left, right, rel_tol=1e-6, abs_tol=1e-9)


for pattern in json.loads(os.environ["REQUIRE_JSON"]):
    if not re.search(pattern, answer):
        print("FAIL: the expression in " + os.environ["KEY"] + " must match the pattern " + pattern)
        sys.exit(1)
for pattern in json.loads(os.environ["FORBID_JSON"]):
    if re.search(pattern, answer):
        print("FAIL: the expression in " + os.environ["KEY"] + " must not match the pattern " + pattern)
        sys.exit(1)

got = query(answer)
if got.get("status") != "success":
    print("FAIL: Prometheus rejected the expression: " + str(got.get("error")))
    sys.exit(1)
want = query(reference)
if want.get("status") != "success":
    print("FAIL: the reference expression failed (author error): " + str(want.get("error")))
    sys.exit(1)

got_kind, got_series = normalise(got)
want_kind, want_series = normalise(want)
if not want_series and not allow_empty:
    print("FAIL: the reference result is empty (author error)")
    sys.exit(1)
if got_kind != want_kind:
    print("FAIL: the expression returns a %s but a %s is required" % (got_kind, want_kind))
    sys.exit(1)
if set(got_series) != set(want_series):
    print("FAIL: the result has %d series and %d are required, or the label sets differ"
          % (len(got_series), len(want_series)))
    sys.exit(1)
for key, values in want_series.items():
    other = got_series[key]
    if len(other) != len(values) or not all(same(a, b) for a, b in zip(other, values)):
        print("FAIL: the values differ for the series " + json.dumps(dict(key)))
        sys.exit(1)
print("PASS: " + os.environ["KEY"] + " returns the required series at the required time")
PY
exit $?
