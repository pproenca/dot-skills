---
title: Wrap a process behind named client functions, not scattered GenServer.call
tags: proc, genserver, api, encapsulation
---

## Wrap a process behind named client functions, not scattered GenServer.call

When `GenServer.call(pid, {:reserve, sku, qty})` appears in controllers, other contexts, and tests, the process's message protocol has leaked across the codebase. Every caller now knows the internal message shapes, so changing them means editing everywhere, and the raw `call`/`cast` tells the reader nothing about intent. The process's public API belongs in its own module as plain functions; the `GenServer.call` lives only inside those functions. Callers see `Inventory.reserve(sku, qty)`, never a message tuple.

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
