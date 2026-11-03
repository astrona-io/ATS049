# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `python3` on your machine.
- You know how `up`, `absent()`, `absent_over_time()`, `changes()` and `timestamp()` behave.

The lab starts a single-node kind cluster with a Prometheus server that holds a fixed dataset, and a pod named `shuttle` with a query helper. Nothing is scraped, so the data never changes.
