---
title: Declare return in every multi-step reactor
tags: dep, return, output, contract
---

## Declare return in every multi-step reactor

A reactor's value to its caller is one step's result, and `return :step_name`
is what designates it. Omit it in a multi-step reactor and the output is
whatever the definition happens to fall back to — an accident of step layout
that silently changes when steps are added, reordered, or renamed. The wrong
default is treating the last-written step as "obviously the result": Reactor
plans a graph, not a script, so "last" is not even well-defined. This matters
doubly under composition, where `compose` exposes exactly the child's returned
value as `result(:composed_step)`.

**Evidence of violation:** a `use Reactor` module containing two or more
step-producing entities (`step`, `compose`, `map`, `switch`, `collect`) with no
top-level `return`. PASS: every multi-step reactor names its output with
`return`. N/A: the target defines no reactor modules, or only single-step
reactors.

```elixir
defmodule Checkout.PlaceOrder do
  use Reactor

  input :cart_id

  step :create_order, Checkout.CreateOrder do
    argument :cart_id, input(:cart_id)
  end

  step :notify_warehouse, Checkout.NotifyWarehouse do
    argument :order, result(:create_order)
  end

  # The caller gets the order — not whichever step the planner finished last.
  return :create_order
end
```

Reference: [Reactor — Getting Started: return](https://reactor.hexdocs.pm/01-getting-started.html)
