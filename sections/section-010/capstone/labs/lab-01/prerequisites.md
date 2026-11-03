# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `python3` on your machine.
- You know the four label matchers, selection by `__name__`, range selectors, `count by`, the lookback rule, `offset` with negative values and the `@` modifier.

The lab starts a single-node kind cluster (Kubernetes 1.35) with a Prometheus server (version 3.5.5) and a `shuttle` pod. The data is generated and the same on every start.
