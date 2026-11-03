# Task

The `bridge`, `shuttle` and `probe` targets of the `starfleet` fleet report to one Prometheus server, and the on-call team needs selectors that return exactly the series they name.

The cluster has a Prometheus server in the namespace `starfleet` with one hour of generated data, from Unix time 1767225600 to 1767229200, and a `shuttle` pod with a query helper. Test an expression before you store it:

```sh
kubectl -n starfleet exec deploy/shuttle -- python /tools/pq.py 'up'
```

The helper evaluates at Unix time 1767229200 by default. Add `--time UNIX` to evaluate at another time, and `--range START END STEP` for a range query. The helper prints one line per series, and a range vector prints the samples under the series line.

Save your five expressions in a file named `answers.yaml`. Each value is one PromQL expression in single quotes:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: answers
  namespace: starfleet
data:
  q1: ''
  q2: ''
  q3: ''
  q4: ''
  q5: ''
```

Apply it, and apply the whole file again after every change:

```sh
kubectl apply -f answers.yaml
```

The grader reads each key, runs the expression against Prometheus and compares the series, the labels and the values with the expected result. A question can also require a technique, such as a modifier or an aggregation.

## Question 1 (key `q1`)

Select the `up` series of the jobs `bridge` and `shuttle`, and no other job, with one selector that uses a regular expression matcher. The grader checks it at the default evaluation time 1767229200.

## Question 2 (key `q2`)

Select the `http_requests_total` series that have the status `500`, for every instance except `shuttle-0:8080`. The grader checks it at the default evaluation time 1767229200.

## Question 3 (key `q3`)

Select every series whose metric name starts with `disk_`, without writing a metric name in front of the braces. The grader checks it at the default evaluation time 1767229200.

## Question 4 (key `q4`)

Return the number of `http_requests_total` series for each job, as one result element per job. The grader checks it at the default evaluation time 1767229200.

## Question 5 (key `q5`)

Return the samples of the last 30 seconds of the `http_requests_total` series of the job `shuttle` that have the status `200`, as a range vector. The grader checks it at the default evaluation time 1767229200.
