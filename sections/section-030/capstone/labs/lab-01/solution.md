# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so that you can continue after a failed check. The values below come from the dataset formulas, not from a recorded run: compare them with your own output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/capstone/labs/lab-01
```

## Step 1: Highest disk usage

A gauge selector accepts a range directly, so no subquery is needed:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'max_over_time(disk_used_bytes[30m])'
```

You should see two lines with the labels `instance`, `job` and `mountpoint`, and without the metric name. The value for `probe-0:9100` is 43600000000, and the value for `probe-1:9100` is 41500000000, its last sample before it stopped.

## Step 2: The silent probe

`absent_over_time` returns 1 when the selector has no sample in the range. The labels come from the equality matchers:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'absent_over_time(up{job="probe",instance="probe-1:9100"}[10m])'
```

You should see:

```text
{instance="probe-1:9100", job="probe"} 1
```

The last sample of `probe-1:9100` is at 1767228600, exactly 10 minutes before the evaluation time, and a range excludes its left boundary.

## Step 3: Spread of the total queue depth

Sum first, then take the spread of the totals over the 30 minutes:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'stddev_over_time(sum by (job) (queue_depth)[30m:1m])'
```

The result has two lines. The value for `bridge` is about 6, and the value for `shuttle` is about 69.2. The totals of `shuttle` rise by 8 per minute, so its spread is large.

## Step 4: Highest rate of status 500 responses

Apply `rate()` to each series with the status 500, add the rates, and put both in a subquery:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'max_over_time(sum by (job) (rate(http_requests_total{status="500"}[1m]))[30m:1m])'
```

The value for `bridge` is about 0.8 and the value for `shuttle` is 1. The counters grow by a constant amount per step, so the rate is the same at every step time.

## Step 5: Fewest targets up

Add the values of `up` inside the subquery, so that each point is the number of targets that were up at that moment, and take the minimum outside:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'min_over_time(sum by (job) (up)[30m:1m])'
```

You should see:

```text
{job="bridge"} 2
{job="probe"} 1
{job="shuttle"} 0
```

The value 1 for `probe` shows that the sum sees the drop when `probe-1:9100` stops being returned, which `sum by (job) (min_over_time(up[30m]))` does not show. The value 0 for `shuttle` comes from the outage of `shuttle-0:8080`.

## Store the answers and submit

Store the five expressions in the ConfigMap `answers`, the same way as in the task:

```sh
kubectl -n starfleet create configmap answers \
  --from-literal=q1='max_over_time(disk_used_bytes[30m])' \
  --from-literal=q2='absent_over_time(up{job="probe",instance="probe-1:9100"}[10m])' \
  --from-literal=q3='stddev_over_time(sum by (job) (queue_depth)[30m:1m])' \
  --from-literal=q4='max_over_time(sum by (job) (rate(http_requests_total{status="500"}[1m]))[30m:1m])' \
  --from-literal=q5='min_over_time(sum by (job) (up)[30m:1m])' \
  --dry-run=client -o yaml | kubectl apply -f -
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/capstone/labs/lab-01
```

Each check prints `PASS` or a reason for the failure.
