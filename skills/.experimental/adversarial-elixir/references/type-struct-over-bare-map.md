---
title: Model domain entities as structs, not free-form maps
tags: type, struct, primitive-obsession, pattern-matching
---

## Model domain entities as structs, not free-form maps

Passing `%{name: name, email: email, plan: plan}` maps around as domain objects is primitive obsession: the map has no name, no guaranteed keys, and no protection against a typo'd key silently becoming `nil`. Every function that receives it must defensively check the shape. A struct names the type, enforces required fields at construction with `@enforce_keys`, and lets every caller pattern-match `%User{}` — a wrong key in a `%User{}` literal or pattern is a compile error, and `user.typo` raises `KeyError` at access. Either way the typo surfaces loudly instead of becoming a silent `nil` that propagates far from its origin.

```elixir
defmodule MyApp.Accounts.User do
  @enforce_keys [:email]
  defstruct [:email, :name, plan: :free]
end

# Callers match on the type; a wrong key is a compile error, not a silent nil.
def greet(%MyApp.Accounts.User{name: name}), do: "Hi #{name}"
```

Reference: [Elixir — Design anti-patterns: "Primitive obsession"](https://hexdocs.pm/elixir/design-anti-patterns.html)
