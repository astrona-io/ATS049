# Classic Histograms And histogram_quantile - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-049-playground-060-01
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** UNTESTED (built without a live run; static checks only)

A single-node kind cluster with Prometheus 3.5.5 and a fixed generated dataset (one hour, 15-second samples from Unix time 1767225600, no scraping), plus a `shuttle` pod with the query helper `/tools/pq.py`. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-060/module-01/playground
astrona destroy ats-049-playground-060-01
```

Host requirements: `kubectl` and `python3`. `astrona destroy` takes the environment name, not the path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `manifests/prometheus.yaml` | Namespace, dataset generator, Prometheus, query helper |
| `docs/overview.md` | What the environment contains and ideas to try |
