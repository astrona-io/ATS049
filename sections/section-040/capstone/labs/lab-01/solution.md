# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running, so you can continue after a failed check. This lab was built without a live run, so compare the values you see with the dataset formulas in the explanations.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/capstone/labs/lab-01
```

The reference answers are these expressions. In the store command, each one goes in as `--from-literal=qN='<expression>'`:

- `q1`: `sum by (job) (rate(http_requests_total{status="500"}[5m])) / sum by (job) (rate(http_requests_total[5m]))`
- `q2`: `min by (job) (up)`
- `q3`: `topk(1, sum by (instance) (rate(http_requests_total[5m])))`
- `q4`: `stddev by (job) (queue_depth)`
- `q5`: `count by (instance) (count by (instance, cpu) (node_cpu_seconds_total))`

## Step 1: Weighted error ratio for each job

Both sides are grouped by `job`, so each job divides by itself, and the numerators and denominators are summed over all instances before the division.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum by (job) (rate(http_requests_total{status="500"}[5m])) / sum by (job) (rate(http_requests_total[5m]))'
```

What to expect: `bridge` about 0.0367 and `shuttle` about 0.2. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q1`. Keep the earlier answers in the same command:

Run the store command with the key q1.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/capstone/labs/lab-01 --keep
```

The check `error-ratio-per-job` now passes.

## Step 2: Lowest up value per job during the shuttle failure

`min by (job) (up)` returns 0 for a job when any of its targets is down. An average would show a value between 0 and 1 and hide which job fails.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'min by (job) (up)' --time 1767228300
```

What to expect: `bridge` 1, `probe` 1 and `shuttle` 0. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q2`. Keep the earlier answers in the same command:

Run the store command with the keys q1 to q2.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/capstone/labs/lab-01 --keep
```

The check `worst-up-per-job` now passes.

## Step 3: Instance with the highest request rate

`sum by (instance) (rate(...))` gives one rate for each instance, and `topk(1, ...)` keeps the largest one, which is `bridge-0` with about 12.6 requests per second.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'topk(1, sum by (instance) (rate(http_requests_total[5m])))'
```

What to expect: One series: `{instance="bridge-0:8080"}` with about 12.6. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q3`. Keep the earlier answers in the same command:

Run the store command with the keys q1 to q3.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/capstone/labs/lab-01 --keep
```

The check `busiest-instance` now passes.

## Step 4: Standard deviation of queue_depth per job

`stddev by (job)` calculates the population standard deviation of the series of each job. `bridge` has the values 30 and 25, which gives 2.5, and `shuttle` has one series, which gives 0.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'stddev by (job) (queue_depth)'
```

What to expect: `{job="bridge"} 2.5` and `{job="shuttle"} 0`. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q4`. Keep the earlier answers in the same command:

Run the store command with the keys q1 to q4.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/capstone/labs/lab-01 --keep
```

The check `queue-spread-per-job` now passes.

## Step 5: Number of CPU cores per instance

The inner `count by (instance, cpu)` gives one series for each core. The outer `count by (instance)` counts those series for each instance, which is the number of cores.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'count by (instance) (count by (instance, cpu) (node_cpu_seconds_total))' --time 1767228600
```

What to expect: `probe-0:9100` 2 and `probe-1:9100` 2. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q5`. Keep the earlier answers in the same command:

Run the store command with the keys q1 to q5.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/capstone/labs/lab-01 --keep
```

The check `cpus-per-instance` now passes.

