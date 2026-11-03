# Solution

All five answers use the same idea: `time()` is the evaluation time, a timestamp-valued metric holds the time of an event, and the difference is an age in seconds. Test each expression with the helper before you store it.

## Task 1: uptime in seconds

Subtract the start time from `time()`:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'time() - process_start_time_seconds'
```

The result has one line for each of `bridge-0`, `bridge-1`, `probe-0` and `shuttle-0`, with the values 90000, 1800, 176400 and 4200. The series of `probe-1` has no sample inside the lookback window at this time, so it has no line. Store it in key `q1`.

## Task 2: minutes since the last backup

Subtract, then divide by 60. The parentheses are required, because division binds tighter than subtraction:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '(time() - backup_last_success_timestamp_seconds) / 60'
```

You should see 40 for `probe-0` and 5 for `shuttle-0`. Store it in key `q2`.

## Task 3: backups older than 15 minutes

Keep the age in seconds and filter with a comparison against 900:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'time() - backup_last_success_timestamp_seconds > 900'
```

Only `probe-0` is returned, with the value 2400. Do not use `bool`, because that would return 1 or 0 instead of the age. Store it in key `q3`.

## Task 4: freshness of the newest sample

`timestamp(up)` returns the stored time of the newest sample, so the freshness is the difference to `time()`. Evaluate at 1767229393:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'time() - timestamp(up)' --time 1767229393
```

The newest sample of every existing series is at 1767229200, so each of the four lines has the value 193. Store it in key `q4`. Do not put `--time` in the stored expression: the grader evaluates it at 1767229393 itself.

## Task 5: uptime in hours below 2 hours

Convert to hours with a division by 3600 and filter below 2:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '(time() - process_start_time_seconds) / 3600 < 2'
```

Two lines remain: `bridge-1` with approximately 0.5 and `shuttle-0` with approximately 1.17 (4200 divided by 3600). Store it in key `q5`.

## Store the answers

Run the reference script or store your own expressions with `kubectl edit`. The graders read the keys `q1` to `q5` from the ConfigMap `answers`.
