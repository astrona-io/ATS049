# Task

After the restart of `bridge-1` and the loss of `probe-1`, the `starfleet` operators ask five questions that mix selectors, counting and time.

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

Count the series of every metric whose name starts with `http_` and whose `status` label has three characters starting with `5`, with one result element per instance. The grader checks it at the default evaluation time 1767229200.

## Question 2 (key `q2`)

Return the `up` series of the job `probe` as they were ten minutes before the evaluation time. The grader checks it at the default evaluation time 1767229200.

## Question 3 (key `q3`)

Return the samples of the last five minutes of `queue_depth` for the `bridge` job, without the instance `bridge-0:8080`, as the window ended at the fixed Unix time 1767227400. The grader checks it at the default evaluation time 1767229200.

## Question 4 (key `q4`)

This answer is checked at the evaluation time 1767228000. Return the number of `up` series per job as they will be ten minutes after the evaluation time. The grader checks it at the evaluation time 1767228000.

## Question 5 (key `q5`)

This answer is checked at the evaluation time 1767228300. Return the `up` and `build_info` series of the instance `shuttle-0:8080` with one selector, without writing a metric name in front of the braces. The grader checks it at the evaluation time 1767228300.
