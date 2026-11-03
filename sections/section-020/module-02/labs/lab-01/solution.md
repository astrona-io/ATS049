# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so that you can continue after a failed check. The values below come from the dataset formulas, not from a recorded run: compare them with your own output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-02/labs/lab-01
```

## Step 1: Change of the queues

`queue_depth` is a gauge, so use `delta()`:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'delta(queue_depth[5m])'
```

The three values should be close to 20 for `bridge-0:8080`, 0 for `bridge-1:8080` and 40 for `shuttle-0:8080`.

## Step 2: Seconds until each disk is full

Divide the free space by the slope. Both probes have samples at Unix time 1767228600:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '(disk_total_bytes - disk_used_bytes) / deriv(disk_used_bytes[15m])' --time 1767228600
```

`probe-0:9100` has 57,000,000,000 free bytes and fills 1,000,000 bytes per second, so the value should be close to 57000. `probe-1:9100` has 58,500,000,000 free bytes and fills 500,000 bytes per second: close to 117000.

## Step 3: Temperature in 30 minutes

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'predict_linear(temperature_celsius[10m], 1800)' --time 1767228600
```

`probe-0:9100` is at 40 degrees and rises 0.4 degrees per minute, so the value should be close to 52. `probe-1:9100` is at 20 degrees and falls 0.2 degrees per minute: close to 14.

## Step 4: Disks that fill within a day

Compare the prediction with the total. The comparison keeps only the series where the prediction is higher:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'predict_linear(disk_used_bytes[1h], 24 * 3600) > disk_total_bytes' --time 1767228600
```

Only `probe-0:9100` should remain, with a value close to 129400000000. `probe-1:9100` is predicted at about 84700000000 and is filtered out.

## Step 5: Counters that reset

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'resets(http_requests_total[1h]) > 0'
```

Four series should remain, all of `bridge-1:8080`, each with the value 1.

## Step 6: Changes of the queues

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'changes(queue_depth[10m])'
```

The values should be 39 for `bridge-0:8080`, 0 for `bridge-1:8080` and 39 for `shuttle-0:8080`.

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
    delta(queue_depth[5m])
  q2: |-
    (disk_total_bytes - disk_used_bytes) / deriv(disk_used_bytes[15m])
  q3: |-
    predict_linear(temperature_celsius[10m], 1800)
  q4: |-
    predict_linear(disk_used_bytes[1h], 24 * 3600) > disk_total_bytes
  q5: |-
    resets(http_requests_total[1h]) > 0
  q6: |-
    changes(queue_depth[10m])
```

Apply it:

```sh
kubectl apply -f configmap-answers.yaml
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-02/labs/lab-01
```

All six checks should pass. Then remove the lab:

```sh
astrona destroy ats-049-lab-020-02
```
