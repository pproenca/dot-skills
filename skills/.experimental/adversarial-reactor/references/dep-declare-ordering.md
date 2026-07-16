---
title: Declare an edge between ordered side effects — lexical order is not execution order
tags: dep, dag, wait-for, ordering
---

## Declare an edge between ordered side effects — lexical order is not execution order

Reactor does not execute steps in the order they appear in the module. It
builds a dependency graph from declared `argument`/`wait_for` templates and
runs every step whose dependencies are satisfied — concurrently, by default,
in task processes. Two steps with no edge between them are a *statement that
their order does not matter*. The wrong default is writing steps in the
intended sequence and trusting the file to be the plan: the day the planner
schedules them together, the payment captures before the inventory reserves.
Order that matters must be an edge — `argument :x, result(:a)` when B consumes
A's data, `wait_for :a` when B merely must follow A.

**Evidence of violation:** two side-effecting steps where the code's own logic
requires one to complete before the other (B voids/consumes/notifies-about what
A creates, or a comment/name states the sequence), and B declares neither an
`argument` sourced from `result(:a)` (directly or transitively) nor a
`wait_for :a`. PASS: every required ordering is realized as a chain of declared
dependencies. N/A: the target's steps are mutually independent — no pair has a
required order.

```elixir
step :reserve_inventory, Checkout.ReserveInventory do
  argument :order, result(:create_order)
end

step :capture_payment, Checkout.CapturePayment do
  argument :order, result(:create_order)
  # No data flows from the reservation, but capturing before
  # reserving must be impossible — say so with an edge.
  wait_for :reserve_inventory
end
```

Reference: [Reactor — Getting Started: dependency-graph execution](https://reactor.hexdocs.pm/01-getting-started.html)
