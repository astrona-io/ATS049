# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running, so you can continue after a failed check. This lab was built without a live run, so compare the values you see with the dataset formulas in the explanations.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-02/labs/lab-01
```

The reference answers are these expressions. In the store command, each one goes in as `--from-literal=qN='<expression>'`:

- `q1`: `topk(2, sum by (instance) (rate(http_requests_total[5m])))`
- `q2`: `bottomk by (job) (1, queue_depth)`
- `q3`: `quantile(0.5, queue_depth)`
- `q4`: `count_values("state", up)`
- `q5`: `sum(rate(http_requests_total{job="bridge", status="500"}[5m])) / sum(rate(http_requests_total{job="bridge"}[5m]))`
- `q6`: `sum(rate(http_request_duration_seconds_sum[5m])) / sum(rate(http_request_duration_seconds_count[5m]))`

## Step 1: Two busiest instances by request rate

`sum by (instance) (rate(...))` gives one value for each instance, and `topk(2, ...)` keeps the two largest. From the dataset formulas they are `bridge-0` (about 12.6) and `bridge-1` (about 9.2).

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'topk(2, sum by (instance) (rate(http_requests_total[5m])))'
```

What to expect: Two series: `bridge-0:8080` about 12.6 and `bridge-1:8080` about 9.2. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q1`. Keep the earlier answers in the same command:

Run the store command with the key q1.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-02/labs/lab-01 --keep
```

The check `top-two-instances-by-rate` now passes.

## Step 2: Series with the lowest queue_depth in each job

`bottomk by (job) (1, queue_depth)` ranks inside each job and returns the whole series, with the metric name and every label. `min by (job)` would lose the `instance` label.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'bottomk by (job) (1, queue_depth)'
```

What to expect: Two series: `queue_depth` of `bridge-1` with 25 and `queue_depth` of `shuttle-0` with 280. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q2`. Keep the earlier answers in the same command:

Run the store command with the keys q1 to q2.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-02/labs/lab-01 --keep
```

The check `lowest-queue-per-job` now passes.

## Step 3: Median queue_depth across instances

`quantile(0.5, queue_depth)` sorts the three values 25, 30 and 280 and returns the middle one.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'quantile(0.5, queue_depth)'
```

What to expect: `{} 30`. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q3`. Keep the earlier answers in the same command:

Run the store command with the keys q1 to q3.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-02/labs/lab-01 --keep
```

The check `median-queue-depth` now passes.

## Step 4: How many targets have each up value

`count_values("state", up)` returns one series for each distinct value of `up` and puts that value into the label `state`.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'count_values("state", up)' --time 1767228300
```

What to expect: `{state="0"} 1` and `{state="1"} 4`. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q4`. Keep the earlier answers in the same command:

Run the store command with the keys q1 to q4.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-02/labs/lab-01 --keep
```

The check `count-up-states` now passes.

## Step 5: Error ratio of the bridge job without averaging

The correct ratio adds the numerators and the denominators over both instances and divides once. From the dataset formulas the result is about 0.8 divided by 21.8, which is about 0.0367.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum(rate(http_requests_total{job="bridge", status="500"}[5m])) / sum(rate(http_requests_total{job="bridge"}[5m]))'
```

What to expect: One series without labels, about 0.0367. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q5`. Keep the earlier answers in the same command:

Run the store command with the keys q1 to q5.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-02/labs/lab-01 --keep
```

The check `weighted-error-ratio-bridge` now passes.

## Step 6: Average request duration across instances

The average duration is the total duration divided by the total number of observations. Summing both rates first weights each instance by its traffic. The result is about 0.2333, not the 0.275 that averaging two averages gives.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum(rate(http_request_duration_seconds_sum[5m])) / sum(rate(http_request_duration_seconds_count[5m]))'
```

What to expect: One series without labels, about 0.2333. Compare with your own output; values from `rate` can carry trailing digits.

Store it as `q6`. Keep the earlier answers in the same command:

Run the store command with the keys q1 to q6.

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-02/labs/lab-01 --keep
```

The check `average-duration-across-instances` now passes.

