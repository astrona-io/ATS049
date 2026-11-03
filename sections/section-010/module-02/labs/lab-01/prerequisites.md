# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `python3` on your machine.
- You know the lookback delta, `offset` with negative values, the `@` modifier with `start()` and `end()`, and how a range query evaluates at each step.

The lab starts a single-node kind cluster (Kubernetes 1.35) with a Prometheus server (version 3.5.5) and a `shuttle` pod. The data is generated and the same on every start.
