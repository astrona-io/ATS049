# Selectors, Matchers And The Series Model — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-049-playground-010-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading
- **Status:** UNTESTED (built without a live run)

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with a Prometheus server (3.5.5) loaded with a fixed, generated dataset of one hour (68 series, one sample every 15 seconds, no scraping) and a `shuttle` pod with the query helper `/tools/pq.py`. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-049-playground-010-01
```

`astrona destroy` takes the environment name (`metadata.name` = `ats-049-playground-010-01`), not the config path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, bootstrap manifest) |
| `manifests/prometheus.yaml` | Namespace, dataset generator, Prometheus, `shuttle` and the query helper |
| `docs/overview.md` | What the environment contains and ideas to try |
