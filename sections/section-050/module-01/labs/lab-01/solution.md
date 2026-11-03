# Solution

Solve this lab on `terminal`. Each step stores one expression in the ConfigMap `answers` and ends with `astrona submit`. Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/module-01/labs/lab-01
```

Every query below uses the evaluation time of the lab, 1767228600. At this time `probe-0` has used 43,000,000,000 bytes and `probe-1` 41,500,000,000 bytes of 100,000,000,000.

## Step 1: The used fraction

Both metrics carry the same labels `instance`, `job` and `mountpoint`, so a plain division pairs them one to one. The division removes the metric name and keeps the labels. Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'disk_used_bytes / disk_total_bytes' --time 1767228600
```

You should see the fractions from the dataset:

```text
{instance="probe-0:9100", job="probe", mountpoint="/"} 0.43
{instance="probe-1:9100", job="probe", mountpoint="/"} 0.415
```

Store it and check it:

```sh
kubectl -n starfleet patch configmap answers --type merge -p '{"data":{"q1":"disk_used_bytes / disk_total_bytes"}}'
astrona submit -c .
```

## Step 2: Filter with a threshold

A comparison without `bool` filters. Only `probe-0` is above 0.42, and its value stays the fraction:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'disk_used_bytes / disk_total_bytes > 0.42' --time 1767228600
```

```text
{instance="probe-0:9100", job="probe", mountpoint="/"} 0.43
```

Store it with key `q2` the same way. The division runs before the comparison because it has higher precedence, so no parentheses are needed.

## Step 3: Flags with bool

Add `bool` after the operator. Both series stay, with the value 1 or 0:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'disk_used_bytes / disk_total_bytes > bool 0.42' --time 1767228600
```

```text
{instance="probe-0:9100", job="probe", mountpoint="/"} 1
{instance="probe-1:9100", job="probe", mountpoint="/"} 0
```

Store it with key `q3`.

## Step 4: Fahrenheit

Multiplication and division have the same precedence and run from left to right, and both run before the addition. `temperature_celsius * 9 / 5 + 32` therefore calculates `((t * 9) / 5) + 32`. The temperatures are 40 and 20 degrees at this time:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'temperature_celsius * 9 / 5 + 32' --time 1767228600
```

```text
{instance="probe-0:9100", job="probe", sensor="cpu"} 104
{instance="probe-1:9100", job="probe", sensor="cpu"} 68
```

Store it with key `q4`. An equal formula such as `temperature_celsius * 1.8 + 32` is also accepted.

## Step 5: Count with bool and sum

Wrap the flags from step 3 in `sum`. One flag is 1, so the answer is 1:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum(disk_used_bytes / disk_total_bytes > bool 0.42)' --time 1767228600
```

```text
{} 1
```

Store it with key `q5`, then run `astrona submit -c .` once more. All five checks should pass. To store all five answers in one step you can run the reference script of the lab, `solution/apply.sh`, which creates the same ConfigMap.
