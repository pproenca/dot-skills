---
title: Avoid a single global Manager GenServer that all traffic funnels through
tags: proc, genserver, bottleneck, registry
---

## Avoid a single global Manager GenServer that all traffic funnels through

A single global `InventoryManager`/`SessionManager` GenServer that every request calls through turns the whole system's throughput into one mailbox processed one message at a time — a serialization bottleneck and a single point of failure whose crash stalls every caller. This is the "one big process manages everything" instinct from single-threaded runtimes. If the work needs no state, don't have the process at all. If it needs *per-key* state, partition it: a `Registry` of one lightweight process per key runs them concurrently and isolates failures.

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
