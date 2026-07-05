---
title: Decompose a god-struct into composed structs by cohesion
tags: type, struct, cohesion, refactor
---

## Decompose a god-struct into composed structs by cohesion

A single `%Order{}` carrying 30-plus fields spanning cart, payment, shipping, and audit couples unrelated concerns: every function that touches an order must know the whole shape, and changes ripple widely. There is also a hard runtime cliff — a struct with 32 or more fields loses its compact internal representation and gets slower to build and update — but the design smell bites well before that. Compose smaller, cohesive structs (or split by lifecycle stage) so each part is owned and matched independently.

```elixir
defmodule MyApp.Orders.Order do
  defstruct [:id, :customer_id, :status, :cart, :payment, :shipping]
end

# Each concern is its own cohesive struct, matched on its own.
defmodule MyApp.Orders.Payment do
  defstruct [:method, :amount, :captured_at]
end
```

Reference: [Elixir — Code anti-patterns: "Structs with 32 fields or more"](https://hexdocs.pm/elixir/code-anti-patterns.html)
