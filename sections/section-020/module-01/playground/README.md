# Counters, rate And increase — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-049-playground-020-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading
- **Status:** UNTESTED (built without a live run; static checks only)

A single-node kind cluster with one Prometheus server (version 3.5.5, no scraping, one hour of generated samples every 15 seconds) and a `shuttle` pod with the query helper. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS049.git -c sections/section-020/module-01/playground
astrona destroy ats-049-playground-020-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifest) |
| `manifests/prometheus.yaml` | Namespace, dataset generator, Prometheus and the `shuttle` helper pod |
| `docs/overview.md` | What the environment contains and ideas to try |
