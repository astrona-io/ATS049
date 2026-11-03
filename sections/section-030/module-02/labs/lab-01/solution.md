# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so that you can continue after a failed check. The values below come from the dataset formulas, not from a recorded run: compare them with your own output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/module-02/labs/lab-01
```

## Step 1: Highest total queue depth

The total comes first, so the sum goes inside the subquery and `max_over_time` goes outside. The subquery has a range of 5 minutes and a step of 1 minute:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'max_over_time(sum by (job) (queue_depth)[5m:1m])' --time 1767227700
```

You should see:

```text
{job="bridge"} 51
{job="shuttle"} 80
```

The form `sum by (job) (max_over_time(queue_depth[5m]))` gives other numbers, because it adds peaks that happened at different times.

## Step 2: Highest request rate

Apply `rate()` to each counter series, add the rates with `sum by (job)`, and put both in a subquery:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'max_over_time(sum by (job) (rate(http_requests_total[1m]))[10m:1m])' --time 1767227700
```

The result has two lines. The value for `bridge` is about 21.8 and the value for `shuttle` is about 5. Do not sum the counters before `rate()`: the restart of `bridge-1:8080` would look like a counter reset in the total.

## Step 3: Lowest health of each job

`min by (job)` inside the subquery gives the lowest value of `up` in each job at every step time, and `min_over_time` outside gives the lowest of those over 20 minutes:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'min_over_time(min by (job) (up)[20m:15s])'
```

You should see:

```text
{job="bridge"} 1
{job="probe"} 1
{job="shuttle"} 0
```

The value 0 for `shuttle` comes from the outage of `shuttle-0:8080` between 1767228000 and 1767228585.

## Step 4: Average total queue depth

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'avg_over_time(sum by (job) (queue_depth)[30m:1m])'
```

You should see:

```text
{job="bridge"} 45
{job="shuttle"} 164
```

The total of `bridge` averages 20 from `bridge-0:8080` plus the constant 25 of `bridge-1:8080`. The queue of `shuttle-0:8080` rises by 2 per step, and its average over the 30 minutes is 164.

## Store the answers and submit

Store the four expressions in the ConfigMap `answers`, the same way as in the task:

```sh
kubectl -n starfleet create configmap answers \
  --from-literal=q1='max_over_time(sum by (job) (queue_depth)[5m:1m])' \
  --from-literal=q2='max_over_time(sum by (job) (rate(http_requests_total[1m]))[10m:1m])' \
  --from-literal=q3='min_over_time(min by (job) (up)[20m:15s])' \
  --from-literal=q4='avg_over_time(sum by (job) (queue_depth)[30m:1m])' \
  --dry-run=client -o yaml | kubectl apply -f -
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/module-02/labs/lab-01
```

Each check prints `PASS` or a reason for the failure.
