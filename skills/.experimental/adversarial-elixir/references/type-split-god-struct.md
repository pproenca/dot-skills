---
title: Decompose a god-struct into composed structs by cohesion
tags: type, struct, cohesion, refactor
---

## Decompose a god-struct into composed structs by cohesion

A single `%Order{}` carrying 30-plus fields spanning cart, payment, shipping, and audit couples unrelated concerns: every function that touches an order must know the whole shape, and changes ripple widely. There is also a hard runtime cliff — a struct with 32 or more fields loses its compact internal representation and gets slower to build and update — but the design smell bites well before that. Compose smaller, cohesive structs (or split by lifecycle stage) so each part is owned and matched independently.

**Evidence of violation:** a `defstruct` (or `embedded_schema`) declaring 32 or more fields — count them; the threshold is the documented runtime-representation cliff, so this rule is numeric. For an Ecto `schema` block, hidden runtime keys count toward the cliff: add `__meta__`, one `*_id` foreign key per `belongs_to`, and 2 for `timestamps()` to the declared `field` count (an `embedded_schema` adds only its declared fields). PASS: every struct in the target has 31 or fewer fields. N/A: the target defines no structs. A 20-field struct that merely smells incohesive is N/A for this gate — note it in `Out of scope` if you must; the FAIL line is 32. Ecto schemas mirroring a wide legacy table are still violations at 32+ (embed or split the schema); cite the field count and the file.

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
