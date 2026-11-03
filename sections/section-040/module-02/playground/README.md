# topk, bottomk, quantile, count_values And Statistics - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-049-playground-040-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED. Built without a live run; static checks only.

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with a Prometheus server (version 3.5.5) that holds a fixed one-hour dataset, and a `shuttle` pod with a query helper. Nothing is scraped. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-040/module-02/playground
astrona destroy ats-049-playground-040-02
```

`astrona destroy` takes the environment name (`metadata.name` = `ats-049-playground-040-02`), not the config path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifest) |
| `manifests/prometheus.yaml` | Namespace, dataset generator, Prometheus, query helper |
| `docs/overview.md` | What the environment contains and ideas to try |
