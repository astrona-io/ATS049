# Vector Matching And Set Operators - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-049-playground-050-02
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED (built without a live run)

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with a Prometheus server (v3.5.5) that holds a fixed one-hour dataset, and a `shuttle` pod with the query helper `/tools/pq.py`. Nothing is scraped and nothing is graded.

## Run it

```sh
astrona run -c .
astrona destroy ats-049-playground-050-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the path. `astrona submit` and `astrona test` do not apply.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, manifest) |
| `manifests/prometheus.yaml` | Namespace, dataset generator, Prometheus, query helper |
| `docs/overview.md` | What is in the box, the dataset and ideas to try |
