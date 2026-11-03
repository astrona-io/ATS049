# Solution

Solve this lab on `terminal`. Test each expression with the helper, store it in `answers.yaml`, apply the file and run `astrona submit` to see which checks pass. Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/module-02/labs/lab-01
```

Right after the start, no check passes, because every key in the ConfigMap `answers` is empty.

## Step 1: Question 1

`offset 10m` moves the selector back by 600 seconds. The result has the three `queue_depth` series with their values at 1767228600.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'queue_depth offset 10m'
```

Put it into `answers.yaml` as the value of `q1`:

```yaml
  q1: 'queue_depth offset 10m'
```

## Step 2: Question 2

`@ 1767227385` pins the selector to that second. The `bridge-1` series still has the value 5 there, before its jump to 25.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'queue_depth @ 1767227385'
```

Put it into `answers.yaml` as the value of `q2`:

```yaml
  q2: 'queue_depth @ 1767227385'
```

## Step 3: Question 3

In a range query, `@ start()` is the same time at every step. At each step the expression subtracts the value at 1767228000 from the value at the step time. The first point is 0, and the queue grows by 40 for each 300 seconds, so the later points are 40, 80, 120 and 160.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'queue_depth{job="shuttle"} - queue_depth{job="shuttle"} @ start()' --range 1767228000 1767229200 300
```

Put it into `answers.yaml` as the value of `q3`:

```yaml
  q3: 'queue_depth{job="shuttle"} - queue_depth{job="shuttle"} @ start()'
```

## Step 4: Question 4

`offset -10m` reads the data at 1767228600. The value is 200, while the plain selector at 1767228000 returns 120.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'queue_depth{job="shuttle"} offset -10m' --time 1767228000
```

Put it into `answers.yaml` as the value of `q4`:

```yaml
  q4: 'queue_depth{job="shuttle"} offset -10m'
```

## Step 5: Question 5

The selector reads the data at 1767228900 minus 300 seconds, which is 1767228600, the last sample of `probe-1`. The value is 1. Without the offset the selector at 1767228900 returns nothing, because the sample is exactly five minutes old and the lookback window is left-open.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up{instance="probe-1:9100"} @ 1767228900 offset 5m'
```

Put it into `answers.yaml` as the value of `q5`:

```yaml
  q5: 'up{instance="probe-1:9100"} @ 1767228900 offset 5m'
```

## Apply and submit

Apply the file and submit:

```sh
kubectl apply -f answers.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/module-02/labs/lab-01
```

Every check should pass. Other expressions that return the same series and values also pass, unless the question requires a technique.
