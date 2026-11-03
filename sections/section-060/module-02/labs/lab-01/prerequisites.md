# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `python3` on your machine.
- You can write PromQL expressions and know the topics of the lessons before this task.

The lab starts a single-node kind cluster with a Prometheus server that holds a generated dataset (one hour of samples every 15 seconds from Unix time 1767225600) and a pod `shuttle` with a query helper. Nothing is scraped.
