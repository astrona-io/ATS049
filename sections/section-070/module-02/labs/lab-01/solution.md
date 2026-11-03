# Solution

Each task uses one tool for one kind of failure: a comparison for a failing target, `absent()` for a missing series, `changes()` for a restart, `timestamp()` for a stale series, and `offset` with `unless` for a series that vanished. Test every expression with the helper before you store it.

## Task 1: failing targets

A failed scrape stores `up` with the value 0, so a comparison filter finds it. Evaluate at 1767228300:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up == 0' --time 1767228300
```

The result is one line: `up{instance="shuttle-0:8080", job="shuttle"} 0`. A comparison filter keeps the metric name. Store it in key `q1`, without `--time`.

## Task 2: a missing series

`absent()` returns 1 when its selector matches nothing. The labels come from the equality matchers of the selector, so the selector must contain only the `instance` matcher:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'absent(up{instance="probe-1:9100"})'
```

The result is `{instance="probe-1:9100"} 1`. If you add `job="probe"` to the selector, the result has two labels, and the check fails. Store it in key `q2`.

## Task 3: restarts in the last hour

The start time of a process changes when it restarts. `changes()` over a range of one hour counts the changes, and a comparison with 0 keeps only the processes that have one:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'changes(process_start_time_seconds[1h]) > 0'
```

The result is `{instance="bridge-1:8080", job="bridge"} 1`. Store it in key `q3`.

## Task 4: stale series

The newest sample of every series is at most 15 seconds old, except for a series that stopped. `time() - timestamp(up)` is the age of the newest sample. Keep the ones above 60 and evaluate at 1767228890:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'time() - timestamp(up) > 60' --time 1767228890
```

The result is `{instance="probe-1:9100", job="probe"} 290`. At that time the series is still inside the 5 minute lookback window. Store it in key `q4`, without `--time`.

## Task 5: series that vanished

Compare `up` now with `up` 10 minutes ago. `unless` keeps the elements of the left side that have no match on the right side:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up offset 10m unless up'
```

The result is `up{instance="probe-1:9100", job="probe"} 1`. Store it in key `q5`.

## Store the answers

Run the reference script or store your own expressions with `kubectl edit`. The graders read the keys `q1` to `q5` from the ConfigMap `answers`.
