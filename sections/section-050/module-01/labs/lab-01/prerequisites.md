# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that `kind` can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `python3` on your machine.
- You know how to select series with `up{job="bridge"}`, and how arithmetic, comparison and the `bool` modifier work on instant vectors.

The lab starts a single-node `kind` cluster with a Prometheus server (version 3.5.5) that holds a fixed dataset and a pod called `shuttle` with a query helper. Nothing is scraped, so every query returns the same result every time.
