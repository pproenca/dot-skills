---
title: Replace lookup-then-write with the atomic primitive
tags: state, ets, registry, race-condition
---

## Replace lookup-then-write with the atomic primitive

ETS and Registry operations are individually atomic; *sequences* of them are not. `lookup` then `insert`, `whereis` then `start_link`, `lookup` then `register` — between the two steps any other scheduler can run the same sequence, so two processes both observe "absent" and both act: duplicate table rows, two servers for one key, a crash on the second registration. This is the single-threaded "I just checked, it's still true" intuition, and it fails probabilistically — clean in tests, corrupting under production concurrency. The runtime provides an atomic primitive for each shape: `insert_new`, `update_counter`, `select_replace` on ETS; `start_child` + `{:error, {:already_started, pid}}` for process-per-key; `Registry.register`'s `{:error, {:already_registered, pid}}` return. Use the primitive, or route every write for that key through one owner process, which serializes them by construction.

**Evidence of violation:** a read of shared registry/table state (`:ets.lookup`/`member`, `Registry.lookup`, `Process.whereis`) whose result branches into a write for the same key (`:ets.insert`, `start_link`/`DynamicSupervisor.start_child` without handling `already_started`, `Registry.register` without handling `already_registered`), in code reachable from more than one process concurrently. PASS: the atomic primitive replaces the sequence; the race's both-act outcome is handled (`already_started`/`already_registered` treated as success); or the sequence runs only inside the single process that owns all writes to that key — the reviewer must cite the owner and how other writers are excluded. N/A: no shared ETS/Registry/named-process writes in the target. Carve-out (citable): the check-then-act is a pure fast-path optimization where losing the race is absorbed (the second write is identical and idempotent) — state why both winners converge.

```elixir
# start-or-reuse without a window: the supervisor arbitrates the race,
# and losing it hands back the winner's pid instead of crashing.
def server_for(sku) do
  case DynamicSupervisor.start_child(MyApp.SkuSupervisor, {MyApp.SkuServer, sku}) do
    {:ok, pid} -> pid
    {:error, {:already_started, pid}} -> pid
  end
end
```

Reference: [Erlang `ets` — concurrency and atomicity guarantees](https://www.erlang.org/doc/apps/stdlib/ets.html)
