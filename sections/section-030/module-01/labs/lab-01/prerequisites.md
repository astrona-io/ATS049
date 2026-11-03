# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `python3` on your machine.
- You know what a range vector is and what `min_over_time`, `quantile_over_time`, `stddev_over_time` and `last_over_time` return for each series.

The lab starts a single-node kind cluster with one Prometheus server (version 3.5.5) that holds a fixed one-hour dataset, and a `shuttle` pod with the query helper. Prometheus scrapes nothing.
