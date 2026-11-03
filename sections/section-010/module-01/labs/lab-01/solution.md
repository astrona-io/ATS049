# Solution

Solve this lab on `terminal`. Test each expression with the helper, store it in `answers.yaml`, apply the file and run `astrona submit` to see which checks pass. Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/module-01/labs/lab-01
```

Right after the start, no check passes, because every key in the ConfigMap `answers` is empty.

## Step 1: Question 1

One selector with `=~` and the alternation `bridge|shuttle` selects the three series of the two jobs. The result has three lines: `bridge-0`, `bridge-1` and `shuttle-0`.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up{job=~"bridge|shuttle"}'
```

Put it into `answers.yaml` as the value of `q1`:

```yaml
  q1: 'up{job=~"bridge|shuttle"}'
```

## Step 2: Question 2

Two matchers in one selector are an AND. `status="500"` keeps the failing requests and `instance!="shuttle-0:8080"` removes the `shuttle` series. Four series remain, two for each `bridge` instance.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'http_requests_total{status="500", instance!="shuttle-0:8080"}'
```

Put it into `answers.yaml` as the value of `q2`:

```yaml
  q2: 'http_requests_total{status="500", instance!="shuttle-0:8080"}'
```

## Step 3: Question 3

A selector in braces without a metric name needs a matcher on `__name__`. The pattern `disk_.*` must match the whole name, so it needs the trailing `.*`. At the evaluation time two series have a recent sample, one for each of `disk_used_bytes` and `disk_total_bytes` of `probe-0`.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py '{__name__=~"disk_.*"}'
```

Put it into `answers.yaml` as the value of `q3`:

```yaml
  q3: '{__name__=~"disk_.*"}'
```

## Step 4: Question 4

`count by (job)` returns one element for each value of `job`. The expected counts are 8 for `bridge` and 2 for `shuttle`.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'count by (job) (http_requests_total)'
```

Put it into `answers.yaml` as the value of `q4`:

```yaml
  q4: 'count by (job) (http_requests_total)'
```

## Step 5: Question 5

A duration in square brackets turns the selector into a range vector. The window is left-open, so with 15 second samples the series has two samples inside `[30s]`.

Test the expression:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'http_requests_total{job="shuttle", status="200"}[30s]'
```

Put it into `answers.yaml` as the value of `q5`:

```yaml
  q5: 'http_requests_total{job="shuttle", status="200"}[30s]'
```

## Apply and submit

Apply the file and submit:

```sh
kubectl apply -f answers.yaml
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-010/module-01/labs/lab-01
```

Every check should pass. Other expressions that return the same series and values also pass, unless the question requires a technique.
