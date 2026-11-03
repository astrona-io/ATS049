# time, timestamp And Age Of An Event: Playground

- **ID:** PLAYGROUND
- **Slug:** ats-049-playground-070-01
- **Type:** Astrona playground: clean environment, no task, no grading

A single-node kind cluster (`kindest/node:v1.35.8`) with a Prometheus server (version 3.5.5) that holds a fixed one-hour dataset and scrapes nothing, and a `shuttle` pod with a query helper. UNTESTED: built without a live run.

## Run it

```sh
astrona run -c .
astrona destroy ats-049-playground-070-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/prometheus.yaml` | Namespace, dataset generator, Prometheus server and the `shuttle` helper pod |
| `docs/overview.md` | What the environment contains, the dataset, the helper and ideas to try |
