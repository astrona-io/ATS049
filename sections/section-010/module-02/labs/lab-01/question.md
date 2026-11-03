# Task

The `bridge-1` target restarted and the `probe-1` target went quiet, and the on-call team asks time questions that need `offset`, `@` and range queries.

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

Return the `queue_depth` of every series as it was ten minutes before the evaluation time. The grader checks it at the default evaluation time 1767229200.

## Question 2 (key `q2`)

Return the `queue_depth` of every series at the fixed Unix time 1767227385, which is 15 seconds before `bridge-1` restarted, whatever the evaluation time is. The grader checks it at the default evaluation time 1767229200.

## Question 3 (key `q3`)

This answer is checked with a range query from 1767228000 to 1767229200 with a step of 300 seconds. For the `shuttle` job, return the `queue_depth` at each step minus the `queue_depth` at the start of the range. The grader checks it at a range query (`--range 1767228000 1767229200 300`).

## Question 4 (key `q4`)

This answer is checked at the evaluation time 1767228000. Return the `queue_depth` of the job `shuttle` as it will be ten minutes after the evaluation time. The grader checks it at the evaluation time 1767228000.

## Question 5 (key `q5`)

Return `up` for the instance `probe-1:9100` as it was five minutes before the fixed Unix time 1767228900. The grader checks it at the default evaluation time 1767229200.
