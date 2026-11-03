# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running, so you can continue after a failed check. This lab was built without a live run, so compare the values you see with the dataset formulas in the explanations.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-01/labs/lab-01
```

The reference answers are these expressions. In the store command, each one goes in as `--from-literal=qN='<expression>'`:

- `q1`: `sum by (job) (rate(http_requests_total[5m]))`
- `q2`: `sum by (instance, mode) (rate(node_cpu_seconds_total[5m]))`
- `q3`: `count by (__name__) ({job="bridge"})`
- `q4`: `count by (job) (up == 0)`
- `q5`: `sum without (instance) (rate(http_requests_total[5m]))`

## Step 1: Request rate per job

The counter `http_requests_total` only grows, so `rate` over `[5m]` turns every series into a per-second value. `sum by (job)` then adds the series of each job and keeps only the label `job`. The rate must be inside the sum.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum by (job) (rate(http_requests_total[5m]))'
```

What to expect: Two series: `bridge` with about 21.8 and `shuttle` with about 5. The job `probe` has no `http_requests_total` series. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q1`. Keep the earlier answers in the same command:

Run the store command with the key q1.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-01/labs/lab-01 --keep
```

The check `request-rate-per-job` now passes.

## Step 2: CPU seconds per second by instance and mode

`rate` runs on the six series of each probe, and `sum by (instance, mode)` removes `cpu` and `job`. At `1767228600` both `probe-0` and `probe-1` have samples, so the result has six series.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum by (instance, mode) (rate(node_cpu_seconds_total[5m]))' --time 1767228600
```

What to expect: Six series; for each instance the `idle` value is about 1.2, `user` about 0.55 and `system` about 0.25. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q2`. Keep the earlier answers in the same command:

Run the store command with the keys q1 to q2.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-01/labs/lab-01 --keep
```

The check `cpu-rate-by-instance-and-mode` now passes.

## Step 3: Series count per metric name for job bridge

The selector `{job="bridge"}` matches the series of every metric of the job. `count by (__name__)` counts them for each metric name, because `__name__` is the one label that survives when you list it in `by`.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'count by (__name__) ({job="bridge"})'
```

What to expect: One line for each metric name of the job; the numbers add up to 35, with 8 for `http_requests_total` and 12 for `http_request_duration_seconds_bucket`. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q3`. Keep the earlier answers in the same command:

Run the store command with the keys q1 to q3.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-01/labs/lab-01 --keep
```

The check `series-per-metric-name` now passes.

## Step 4: Number of failed targets per job

`up == 0` keeps only the series with the value 0. `count by (job)` counts what is left. At `1767228300` only `shuttle-0` is down, so one series remains.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'count by (job) (up == 0)' --time 1767228300
```

What to expect: One line: `{job="shuttle"} 1`. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q4`. Keep the earlier answers in the same command:

Run the store command with the keys q1 to q4.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-01/labs/lab-01 --keep
```

The check `failed-targets-per-job` now passes.

## Step 5: Request rate with every label except instance

`sum without (instance)` removes only `instance` and groups by everything else. The rate comes first, inside the sum. The result has the labels `job`, `method` and `status`.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum without (instance) (rate(http_requests_total[5m]))'
```

What to expect: Six series, one for each combination of `job`, `method` and `status`. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q5`. Keep the earlier answers in the same command:

Run the store command with the keys q1 to q5.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-01/labs/lab-01 --keep
```

The check `rate-without-instance` now passes.

