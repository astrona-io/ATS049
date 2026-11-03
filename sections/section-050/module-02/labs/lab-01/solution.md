# Solution

Solve this lab on `terminal`. Each step stores one expression in the ConfigMap `answers`. Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-050/module-02/labs/lab-01
```

Run `astrona submit -c .` after each step to check the answer you stored.

## Step 1: Add two counters with ignoring

The two sides differ only in the label `status`, so a plain `+` finds no pairs. `ignoring(status)` leaves that label out of the match, and it also removes `status` from the result:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'http_requests_total{status="200"} + ignoring(status) http_requests_total{status="500"}'
```

```text
{instance="bridge-0:8080", job="bridge", method="GET"} 137840
{instance="bridge-0:8080", job="bridge", method="POST"} 28020
{instance="bridge-1:8080", job="bridge", method="GET"} 14760
{instance="bridge-1:8080", job="bridge", method="POST"} 1800
{instance="shuttle-0:8080", job="shuttle", method="GET"} 68800
```

Store the expression under `q1`:

```sh
kubectl -n starfleet patch configmap answers --type merge -p '{"data":{"q1":"http_requests_total{status=\"200\"} + ignoring(status) http_requests_total{status=\"500\"}"}}'
```

Writing `on(instance, job, method)` instead gives the same result.

## Step 2: Copy the version label

`queue_depth` and `build_info` both have one series per instance, so match on `instance` and copy `version` from the right side:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'queue_depth * on(instance) group_left(version) build_info'
```

```text
{instance="bridge-0:8080", job="bridge", version="1.4.2"} 30
{instance="bridge-1:8080", job="bridge", version="1.5.0"} 25
{instance="shuttle-0:8080", job="shuttle", version="2.0.1"} 280
```

Store the expression `queue_depth * on(instance) group_left(version) build_info` under `q2`.

## Step 3: Copy the team label to many series

The five 500 counters meet three `team_info` series, so this is a many-to-one match. The counters are on the left, and the info metric is on the right and has one series per instance. Use `group_left(team)`:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'http_requests_total{status="500"} * on(instance) group_left(team) team_info'
```

```text
{instance="bridge-0:8080", job="bridge", method="GET", status="500", team="ops"} 1840
{instance="bridge-0:8080", job="bridge", method="POST", status="500", team="ops"} 820
{instance="bridge-1:8080", job="bridge", method="GET", status="500", team="ops"} 360
{instance="bridge-1:8080", job="bridge", method="POST", status="500", team="ops"} 0
{instance="shuttle-0:8080", job="shuttle", method="GET", status="500", team="logistics"} 4400
```

Store the expression under `q3`. Without `group_left` the query fails with an error about the match group.

## Step 4: Select with and

Use `up == 0` on the right side, and `and on(instance)` to keep the left series whose `instance` appears on the right. The evaluation time of this question is 1767228300:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'queue_depth and on(instance) up == 0' --time 1767228300
```

```text
queue_depth{instance="shuttle-0:8080", job="shuttle"} 160
```

Store it under `q4`. The expression `queue_depth and up == 0` returns the same result and is also accepted.

## Step 5: Exclude with unless

`unless` keeps the left series without a partner on the right, so it returns the other two instances:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'queue_depth unless on(instance) up == 0' --time 1767228300
```

```text
queue_depth{instance="bridge-0:8080", job="bridge"} 10
queue_depth{instance="bridge-1:8080", job="bridge"} 25
```

Store it under `q5` and run `astrona submit -c .` again. All five checks should pass. The script `solution/apply.sh` of the lab stores all five answers at once.
