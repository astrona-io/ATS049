# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so that you can continue after a failed check. The values below come from the dataset formulas, not from a recorded run: compare them with your own output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/module-01/labs/lab-01
```

## Step 1: Lowest queue depth in 10 minutes

`min_over_time` returns the smallest sample of each series in the window. The window must be `10m`: the gauge of `bridge-0:8080` has a cycle of 10 minutes, and a `5m` window misses its low point.

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'min_over_time(queue_depth[10m])'
```

You should see:

```text
{instance="bridge-0:8080", job="bridge"} 10
{instance="bridge-1:8080", job="bridge"} 25
{instance="shuttle-0:8080", job="shuttle"} 202
```

`shuttle-0:8080` rises by 2 per step, and its oldest sample in the window, at step 201, is 202.

## Step 2: The 0.9 quantile of the temperature

`quantile_over_time` takes the quantile first and the range vector second:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'quantile_over_time(0.9, temperature_celsius[10m])'
```

The result has one line, for `probe-0:9100`, with a value close to 43.61. The series `probe-1:9100` has no sample in the last 10 minutes, so it does not appear. The 40 samples of `probe-0:9100` rise by 0.1 per step from 40.1 to 44, and 90 percent of them lie below about 43.6.

## Step 3: Spread of the bridge queue

Put the label matcher in the selector and use a `5m` range:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'stddev_over_time(queue_depth{job="bridge"}[5m])'
```

You should see two lines. The value for `bridge-0:8080` should be close to 5.77, and the value for `bridge-1:8080` is 0, because that gauge is constant.

## Step 4: The newest temperature of every probe

`last_over_time` looks back as far as its range, and it keeps the metric name. A `15m` window reaches the last sample of `probe-1:9100`, which is at Unix time 1767228600:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'last_over_time(temperature_celsius[15m])'
```

You should see two lines with the name `temperature_celsius`. The value for `probe-0:9100` is 44, and the value for `probe-1:9100` is 20, from the formula 30 - 0.05 * 200.

## Store the answers and submit

Store the four expressions in the ConfigMap `answers`, the same way as in the task:

```sh
kubectl -n starfleet create configmap answers \
  --from-literal=q1='min_over_time(queue_depth[10m])' \
  --from-literal=q2='quantile_over_time(0.9, temperature_celsius[10m])' \
  --from-literal=q3='stddev_over_time(queue_depth{job="bridge"}[5m])' \
  --from-literal=q4='last_over_time(temperature_celsius[15m])' \
  --dry-run=client -o yaml | kubectl apply -f -
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-030/module-01/labs/lab-01
```

Each check prints `PASS` or a reason for the failure.
