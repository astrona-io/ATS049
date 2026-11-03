# Solution

Solve this lab on `terminal`. Each step stores one expression in the ConfigMap `answers`. Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/capstone/labs/lab-01
```

Run `astrona submit -c .` after each step to check the answer you stored.

## Step 1: The error ratio per job

Sum both rates by `job` first, then divide. Both sides then have only the label `job`, so they pair one to one:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum by (job) (rate(http_requests_total{status="500"}[5m])) / sum by (job) (rate(http_requests_total[5m]))'
```

The dataset gives the expected values. For `bridge`, the error rate is 0.8 requests per second and the total is 21.8, so the ratio is about 0.0367. For `shuttle` it is 1 of 5, about 0.2. Compare your output with these. Store it under `q1`:

```sh
kubectl -n starfleet patch configmap answers --type merge -p '{"data":{"q1":"sum by (job) (rate(http_requests_total{status=\"500\"}[5m])) / sum by (job) (rate(http_requests_total[5m]))"}}'
```

## Step 2: The share of the budget

Division is left associative, so adding `/ on(job) error_budget_ratio` divides the ratio of step 1 by the budget. For `bridge` the result is about 0.0367 divided by 0.02, which is about 1.83, and for `shuttle` it is about 2.0. Store this expression under `q2`:

```text
sum by (job) (rate(http_requests_total{status="500"}[5m])) / sum by (job) (rate(http_requests_total[5m])) / on(job) error_budget_ratio
```

## Step 3: Old backups on live instances

The comparison binds tighter than `and`, so `up == 1` runs before the set operator, and the age is filtered before it is matched:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'time() - backup_last_success_timestamp_seconds > 1800 and on(instance) up == 1'
```

```text
{instance="probe-0:9100", job="probe"} 2400
```

The backup of `shuttle-0` is 300 seconds old and is filtered out. The backup of `probe-0` froze at 1767226800 and is 2400 seconds old, and `probe-0` is up. Store it under `q3`.

## Step 4: Annotate the queue depths

A filter runs after arithmetic, so the filter needs parentheses to run first. Then two many-to-one matches add the labels:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '(queue_depth > 26) * on(instance) group_left(version) build_info * on(instance) group_left(team) team_info'
```

```text
{instance="bridge-0:8080", job="bridge", team="ops", version="1.4.2"} 30
{instance="shuttle-0:8080", job="shuttle", team="logistics", version="2.0.1"} 280
```

Store it under `q4`. Writing the filter at the end, as `queue_depth * on(instance) group_left(version) build_info * on(instance) group_left(team) team_info > 26`, gives the same series and is also accepted.

## Step 5: Count the targets that are down

Filter `up` for zero and count the series. The evaluation time is 1767228300:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'count(up == 0)' --time 1767228300
```

```text
{} 1
```

Store it under `q5` and run `astrona submit -c .` again. All five checks should pass. The script `solution/apply.sh` of the lab stores all five answers at once.
