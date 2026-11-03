# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `python3` on your machine.
- You can write PromQL aggregation expressions with `by` and `without`, and you know how `rate` and the range selector work.

The lab starts a single-node kind cluster with a Prometheus server (version 3.5.5) that holds a fixed dataset, and a pod `shuttle` with a query helper. The commands for the lab are in the README of this folder.
