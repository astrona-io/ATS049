# The over_time Functions — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-049-playground-030-01
- **Type:** Astrona playground — clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with one Prometheus server (version 3.5.5) that holds a fixed, generated one-hour dataset and scrapes nothing, and a `shuttle` pod that runs a small query helper. Nothing to submit. Status: UNTESTED (built without a live run).

## Run it

```sh
astrona run -c .
astrona destroy ats-049-playground-030-01
```

`astrona destroy` takes the environment name (`metadata.name` = `ats-049-playground-030-01`), not the config path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/prometheus.yaml` | Namespace `starfleet`, the dataset generator, Prometheus and the `shuttle` helper pod |
| `docs/overview.md` | What the environment contains, how to use the helper, and ideas to try |
