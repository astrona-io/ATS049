# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so that you can continue after a failed check. The values below come from the dataset formulas, not from a recorded run: compare them with your own output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-01/labs/lab-01
```

## Step 1: Request rate per instance

`rate()` goes first, on each series. `sum without (method, status)` then removes the two labels you do not want and keeps `instance` and `job`:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum without (method, status) (rate(http_requests_total[5m]))'
```

The three lines should be close to 12.6 for `bridge-0:8080`, 9.2 for `bridge-1:8080` and 5 for `shuttle-0:8080`. Those are the sums of the per-series rates 10 + 2 + 0.4 + 0.2, 8 + 1 + 0.2 + 0 and 4 + 1.

## Step 2: Errors in the last 10 minutes

`increase()` returns a count. Select the 500 series, use a `10m` range, and add the series up per instance:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum by (instance) (increase(http_requests_total{status="500"}[10m]))'
```

The values should be close to 360 for `bridge-0:8080` (0.4 and 0.2 per second for 600 seconds), 120 for `bridge-1:8080` and 600 for `shuttle-0:8080`.

## Step 3: The rate across the restart

The restart of `bridge-1:8080` is at Unix time 1767227400, so a 5 minute range that ends at 1767227550 holds it. Take `rate()` of every series, then sum:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum(rate(http_requests_total{job="bridge"}[5m]))' --time 1767227550
```

The value should be close to 21.3. It is a little below the steady value of 21.8, because each reset loses one step of growth. A subquery such as `rate(sum(...)[5m:15s])` gives about 523 and is wrong.

## Step 4: Instant rate of POST requests

`irate()` uses the last two samples. `bridge-0:8080` has POST 200 at 2 per second and POST 500 at 0.2 per second, `bridge-1:8080` has 1 and 0:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum by (instance) (irate(http_requests_total{job="bridge",method="POST"}[1m]))'
```

The values should be close to 2.2 and 1.

## Step 5: Error share per job

Divide two aggregated rates. Both sides keep only `job`, so the labels match:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'sum by (job) (rate(http_requests_total{status="500"}[5m])) / sum by (job) (rate(http_requests_total[5m]))'
```

The values should be close to 0.0367 for `bridge` (0.8 divided by 21.8) and 0.2 for `shuttle` (1 divided by 5).

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
    sum without (method, status) (rate(http_requests_total[5m]))
  q2: |-
    sum by (instance) (increase(http_requests_total{status="500"}[10m]))
  q3: |-
    sum(rate(http_requests_total{job="bridge"}[5m]))
  q4: |-
    sum by (instance) (irate(http_requests_total{job="bridge",method="POST"}[1m]))
  q5: |-
    sum by (job) (rate(http_requests_total{status="500"}[5m])) / sum by (job) (rate(http_requests_total[5m]))
```

Apply it:

```sh
kubectl apply -f configmap-answers.yaml
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-01/labs/lab-01
```

All five checks should pass. Then remove the lab:

```sh
astrona destroy ats-049-lab-020-01
```
