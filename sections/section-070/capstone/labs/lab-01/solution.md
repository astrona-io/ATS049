# Solution

The tasks combine age computations (`time()` minus a timestamp-valued metric, with unit conversion) and freshness tests (`unless`, `absent_over_time()` and `changes()`). Test each expression with the helper before you store it.

## Task 1: backups older than 30 minutes, in minutes

Subtract, divide by 60 in parentheses, then filter:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '(time() - backup_last_success_timestamp_seconds) / 60 > 30'
```

The result is `{instance="probe-0:9100", job="probe"} 40`. The source `shuttle-0` has an age of 5 minutes and is filtered out. Store it in key `q1`.

## Task 2: backup series that vanished

Compare the metric 10 minutes ago with now. `unless` keeps the old series that have no match now:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'backup_last_success_timestamp_seconds offset 10m unless backup_last_success_timestamp_seconds'
```

The result is the series of `probe-1` with its old value, 1767226800. Its name is kept, because `unless` returns the left side unchanged. Store it in key `q2`.

## Task 3: absent over 10 minutes

`absent_over_time()` takes a range vector and returns 1 when the range holds no sample. The last sample of `probe-1` is at 1767228600, and a range of 10 minutes at 1767229200 is open at its left edge, so it excludes that sample:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'absent_over_time(up{instance="probe-1:9100"}[10m])'
```

The result is `{instance="probe-1:9100"} 1`. Store it in key `q3`.

## Task 4: restarts in the last 45 minutes

Use `changes()` on the start time with a range that reaches back past the restart at 1767227400, and keep values above 0:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'changes(process_start_time_seconds[45m]) > 0'
```

The result is `{instance="bridge-1:8080", job="bridge"} 1`. Store it in key `q4`.

## Task 5: longest uptime in days

Compute the uptime, take the maximum, which removes the labels, and divide by 86400 (the seconds in one day):

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'max(time() - process_start_time_seconds) / 86400'
```

The longest uptime is 176400 seconds, from `probe-0`, so the result is approximately 2.04 days. The exact digits can differ from a hand calculation. Store it in key `q5`.

## Store the answers

Run the reference script or store your own expressions with `kubectl edit`. The graders read the keys `q1` to `q5` from the ConfigMap `answers`.
