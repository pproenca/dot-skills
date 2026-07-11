---
title: Avoid a single global Manager GenServer that all traffic funnels through
tags: proc, genserver, bottleneck, registry
---

## Avoid a single global Manager GenServer that all traffic funnels through

A single global `InventoryManager`/`SessionManager` GenServer that every request calls through turns the whole system's throughput into one mailbox processed one message at a time — a serialization bottleneck and a single point of failure whose crash stalls every caller. This is the "one big process manages everything" instinct from single-threaded runtimes. If the work needs no state, don't have the process at all. If it needs *per-key* state, partition it: a `Registry` of one lightweight process per key runs them concurrently and isolates failures.

**Evidence of violation:** a single globally-named GenServer (`name: __MODULE__` or a fixed registered name) sitting on the request path (called from controllers, LiveViews, channels, or other contexts) whose state or `handle_call` clauses are keyed per entity — a map of id→data, or every call carrying a key the callback uses to select a slice of state. That shape is partitionable by construction, and the singleton serializes it. PASS: per-key work runs in per-key processes (Registry/DynamicSupervisor or `:via` tuples), lives in ETS, or the process is not on the request path (a periodic janitor, a startup task). N/A: no globally-named GenServer in the target. Carve-out (citable): the work genuinely requires global serialization — one shared external resource, a strict global ordering requirement — cite the resource or invariant; "it holds all the state" is the violation, not the carve-out.

```elixir
# Per-key processes under a DynamicSupervisor + Registry — concurrent, isolated.
# A :via tuple + start-or-reuse avoids the check-then-act race of a bare lookup.
def reserve(sku, qty) do
  case DynamicSupervisor.start_child(MyApp.SkuSupervisor, {MyApp.SkuServer, sku}) do
    {:ok, pid} -> pid
    {:error, {:already_started, pid}} -> pid
  end
  |> GenServer.call({:reserve, qty})
end
```

Reference: [Saša Jurić — "To spawn, or not to spawn?"](https://www.theerlangelist.com/article/spawn_or_not)
