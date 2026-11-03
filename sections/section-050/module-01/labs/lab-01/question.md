# Question

Solve this question on: `terminal`

The `probe` instances report their disk usage and temperature. A review of the disks needs five PromQL expressions. Evaluate every expression at Unix time `1767228600`, the last moment at which both `probe-0` and `probe-1` have samples. The graders use this time.

Store each expression as text in the ConfigMap `answers` in the namespace `starfleet`, under the key named in the task. One way is to edit the ConfigMap with `kubectl -n starfleet edit configmap answers` and add the keys under `data:`. Test an expression first with the query helper, for example:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up' --time 1767228600
```

1. Key `q1`: the fraction of each disk that is used, that is `disk_used_bytes` divided by `disk_total_bytes`. The result must keep the labels `instance`, `job` and `mountpoint`.

2. Key `q2`: the same fraction, but only for the disks that are more than 42 percent full. The result keeps the fraction as its value.

3. Key `q3`: for every disk, the value 1 when it is more than 42 percent full and the value 0 when it is not. Both disks must be in the result.

4. Key `q4`: the CPU temperature of each `probe` in degrees Fahrenheit. The formula is Celsius times 9, divided by 5, plus 32. Use the metric `temperature_celsius`.

5. Key `q5`: the number of disks that are more than 42 percent full, as one series without labels. Count them with the `bool` modifier and `sum`.

`kubectl` already points at the cluster. The graders read the expressions from the ConfigMap, run them at the fixed time and compare the series, the labels and the values with the expected result.
