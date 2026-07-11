---
title: Wrap a process behind named client functions, not scattered GenServer.call
tags: proc, genserver, api, encapsulation
---

## Wrap a process behind named client functions, not scattered GenServer.call

When `GenServer.call(pid, {:reserve, sku, qty})` appears in controllers, other contexts, and tests, the process's message protocol has leaked across the codebase. Every caller now knows the internal message shapes, so changing them means editing everywhere, and the raw `call`/`cast` tells the reader nothing about intent. The process's public API belongs in its own module as plain functions; the `GenServer.call` lives only inside those functions. Callers see `Inventory.reserve(sku, qty)`, never a message tuple.

**Evidence of violation:** a `GenServer.call/2,3`, `GenServer.cast/2`, or `send/2` with an explicit message tuple/atom, appearing in any module other than the one that owns the matching `handle_call`/`handle_cast`/`handle_info` — greppable: search the target for `GenServer.call(`/`GenServer.cast(` outside the server module (this may require looking beyond the diff for the owning module). PASS: every external interaction with the process goes through named client functions defined in the server's own module. N/A: the target defines or calls no GenServers. Test files exercising the server's public functions are fine; tests asserting on raw message tuples of another module's server count as violations (the protocol leaked).

```elixir
defmodule MyApp.Inventory do
  use GenServer

  # Public client API — the only thing callers touch.
  def reserve(sku, qty), do: GenServer.call(__MODULE__, {:reserve, sku, qty})

  # Server callbacks — the message protocol stays private.
  def handle_call({:reserve, sku, qty}, _from, state), do: # ...
end
```

Reference: [Elixir — Process anti-patterns: "Scattered process interfaces"](https://hexdocs.pm/elixir/process-anti-patterns.html)
