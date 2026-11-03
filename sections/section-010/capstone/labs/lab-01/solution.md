# Solution

Solve this lab on `terminal`. Test each expression with the helper, store it in `answers.yaml`, apply the file and run `astrona submit` to see which checks pass. Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/capstone/labs/lab-01
```

Right after the start, no check passes, because every key in the ConfigMap `answers` is empty.

## Step 1: Question 1

The selector matches the name with `http_.*` and the status with `5..`. The duration histogram has no `status` label and the pattern cannot match an empty value, so only the `http_requests_total` series with status 500 remain. The counts are 2 for each `bridge` instance and 1 for `shuttle-0`.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'count by (instance) ({__name__=~"http_.*", status=~"5.."})'
```

Put it into `answers.yaml` as the value of `q1`:

```yaml
  q1: 'count by (instance) ({__name__=~"http_.*", status=~"5.."})'
```

## Step 2: Question 2

Ten minutes before the evaluation time is 1767228600, the last sample of `probe-1`. Both `probe` targets appear, each with the value 1.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up{job="probe"} offset 10m'
```

Put it into `answers.yaml` as the value of `q2`:

```yaml
  q2: 'up{job="probe"} offset 10m'
```

## Step 3: Question 3

The selector keeps only `bridge-1`. The window `(1767227100, 1767227400]` holds 20 samples: the value 5 until the restart and the value 25 at 1767227400.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'queue_depth{job="bridge", instance!="bridge-0:8080"}[5m] @ 1767227400'
```

Put it into `answers.yaml` as the value of `q3`:

```yaml
  q3: 'queue_depth{job="bridge", instance!="bridge-0:8080"}[5m] @ 1767227400'
```

## Step 4: Question 4

The modifier goes inside the aggregation, on the selector. At 1767228600 all five targets have a sample, so the counts are 2 for `bridge`, 1 for `shuttle` and 2 for `probe`.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'count by (job) (up offset -10m)' --time 1767228000
```

Put it into `answers.yaml` as the value of `q4`:

```yaml
  q4: 'count by (job) (up offset -10m)'
```

## Step 5: Question 5

One selector with `__name__=~"up|build_info"` returns both series. At 1767228300 the `up` value is 0, because `shuttle-0` is failing its scrapes, and the `build_info` value is 1.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '{__name__=~"up|build_info", instance="shuttle-0:8080"}' --time 1767228300
```

Put it into `answers.yaml` as the value of `q5`:

```yaml
  q5: '{__name__=~"up|build_info", instance="shuttle-0:8080"}'
```

## Apply and submit

Apply the file and submit:

```sh
kubectl apply -f answers.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/capstone/labs/lab-01
```

Every check should pass. Other expressions that return the same series and values also pass, unless the question requires a technique.
