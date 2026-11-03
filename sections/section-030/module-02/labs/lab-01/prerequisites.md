# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `python3` on your machine.
- You know the subquery syntax `expr[range:step]`, and you know what `rate()` and `sum by (label)` return.

The lab starts a single-node kind cluster with one Prometheus server (version 3.5.5) that holds a fixed one-hour dataset, and a `shuttle` pod with the query helper. Prometheus scrapes nothing.
