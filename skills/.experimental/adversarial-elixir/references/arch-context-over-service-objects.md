---
title: Collapse stateless Service/Manager modules into contexts
tags: arch, context, phoenix, layering
---

## Collapse stateless Service/Manager modules into contexts

A `OrderService` / `OrderManager` module whose every function takes an `%Order{}` as the first argument is an object with methods wearing a module's clothes. It reproduces the OO "service object" tier — one service class per entity — that Phoenix contexts already replace. Elixir groups behavior by *business capability* (a context like `Orders`, `Billing`, `Catalog`), not by wrapping a single struct. The refactor is not a rename: it collapses a per-entity service layer into a smaller set of capability-oriented context modules, and functions stop pretending the struct is a `this`.

**Evidence of violation:** a stateless module (no `use GenServer`/`use Agent`, no `handle_*` callbacks) named `*Service`, `*Manager`, `*Handler`, or `*Processor` whose public functions all operate on the same single struct/schema (take it as first argument or immediately load it by id) — an entity's method bag, not a capability. PASS: behavior lives in capability-named context modules (`Orders`, `Billing`), or the suspect module orchestrates across several schemas/capabilities (that is a context wearing an unfortunate name — flag the name in `Out of scope`, not as a FAIL). N/A: the target defines no such modules. Carve-out (citable): the module is a real OTP process (its `use GenServer` and callbacks are visible) — process design is judged by the `proc-` rules instead.

```elixir
# One context per business capability — not one "service" per struct.
defmodule MyApp.Orders do
  alias MyApp.{Repo, Orders.Order, Orders.LineItem}

  def place_order(customer, cart) do
    # orchestrates the whole capability, calling pure helpers + Repo
  end

  def cancel_order(%Order{} = order), do: # ...
end
```

Reference: [Phoenix — Contexts group related functionality behind a boundary](https://hexdocs.pm/phoenix/contexts.html)
