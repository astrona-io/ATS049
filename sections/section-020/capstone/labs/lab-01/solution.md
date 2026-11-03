# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so that you can continue after a failed check. The values below come from the dataset formulas, not from a recorded run: compare them with your own output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/capstone/labs/lab-01
```

## Step 1: Hours until each disk is full

The disks are gauges that fill evenly, so the slope comes from `deriv()`. Free space divided by the slope gives seconds, and dividing by 3600 gives hours:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '(disk_total_bytes - disk_used_bytes) / deriv(disk_used_bytes[15m]) / 3600' --time 1767228600
```

The values should be close to 15.83 for `probe-0:9100` (57,000 seconds) and 32.5 for `probe-1:9100` (117,000 seconds).

## Step 2: The request rate across the restart

Take `rate()` of every series first, then add up per instance:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum by (instance) (rate(http_requests_total{job="bridge"}[5m]))' --time 1767227550
```

`bridge-0:8080` should be close to 12.6. `bridge-1:8080` should be close to 8.7, below its steady value of 9.2, because each of its four series loses one step of growth at the reset.

## Step 3: Resets per instance

`resets()` works on every series, and `sum by (instance)` adds the counts up:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum by (instance) (resets(http_requests_total[1h]))'
```

You should see 0 for `bridge-0:8080`, 4 for `bridge-1:8080` (one for each of its four counters) and 0 for `shuttle-0:8080`.

## Step 4: Queue growth per minute

`deriv()` returns items per second, so multiply by 60:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'deriv(queue_depth{job="shuttle"}[5m]) * 60'
```

The queue of `shuttle-0:8080` grows by 2 in every 15 seconds, so the value should be close to 8.

## Step 5: The error share over an hour

The hour holds the restart, so use `increase()`, which repairs resets. Add each side up to one value and divide:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum(increase(http_requests_total{status="500"}[1h])) / sum(increase(http_requests_total[1h]))'
```

The value should be close to 0.067.

## Store the answers and grade them

Save this as `configmap-answers.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: answers
  namespace: starfleet
data:
  q1: |-
    (disk_total_bytes - disk_used_bytes) / deriv(disk_used_bytes[15m]) / 3600
  q2: |-
    sum by (instance) (rate(http_requests_total{job="bridge"}[5m]))
  q3: |-
    sum by (instance) (resets(http_requests_total[1h]))
  q4: |-
    deriv(queue_depth{job="shuttle"}[5m]) * 60
  q5: |-
    sum(increase(http_requests_total{status="500"}[1h])) / sum(increase(http_requests_total[1h]))
```

Apply it:

```sh
kubectl apply -f configmap-answers.yaml
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/capstone/labs/lab-01
```

All five checks should pass. Then remove the lab:

```sh
astrona destroy ats-049-capstone-020
```
