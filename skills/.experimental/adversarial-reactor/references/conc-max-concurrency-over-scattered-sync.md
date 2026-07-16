---
title: Cap load with run-level max_concurrency, not async? false scattered across steps
tags: conc, max-concurrency, async, tuning
---

## Cap load with run-level max_concurrency, not async? false scattered across steps

When a reactor overwhelms a resource, the reflex fix is to mark steps
`async? false` one by one until the pressure stops. That does not cap
concurrency — it deletes it: each marked step now serializes into the main
process, independent steps that could overlap no longer do, and the planner's
scheduling wins are gone for every run of that reactor. The run option
`max_concurrency` (default `System.schedulers_online/0`) is the actual knob:
it bounds how many steps run at once while leaving the DAG free to fill that
budget, and `concurrency_key` shares one budget across reactor instances.
`async? false` on a step is a statement about *that step's semantics* (it must
run in the calling process), not a load-management tool.

**Evidence of violation:** three or more steps marked `async? false` in one
reactor, with no `max_concurrency` passed at any `Reactor.run` call site of
that reactor, and no per-step semantic reason (process-local state, sandbox)
evident or cited. PASS: load is bounded via `max_concurrency`/
`concurrency_key` at run time; `async? false` appears only on steps with a
process-affinity reason. N/A: at most a stray step is synchronous, or the
target never tunes concurrency.

```elixir
Reactor.run(
  Imports.BackfillCatalog,
  %{source: source},
  %{},
  # Bound the whole run; the planner still overlaps independent steps.
  max_concurrency: 8
)
```

Reference: [Reactor — Async Workflows guide](https://reactor.hexdocs.pm/03-async-workflows.html)
