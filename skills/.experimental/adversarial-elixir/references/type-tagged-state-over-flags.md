---
title: Encode state as one atom/tagged tuple, not several booleans or strings
tags: type, boolean-obsession, atoms, state
---

## Encode state as one atom/tagged tuple, not several booleans or strings

Representing a status as several booleans — `%{active: true, suspended: false, pending: false}` — makes illegal states representable (active *and* suspended) and forces every reader to reconstruct the state from a combination of flags. A free-form `status: "active"` string has the same problem with typo risk added. A single `status` atom makes the state one value you pattern-match on, and mutually-exclusive states become unrepresentable by construction.

**Incorrect (illegal combinations possible, logic scattered):**

```elixir
if user.active and not user.suspended and not user.pending, do: allow(user)
```

**Correct (one value, matched directly):**

```elixir
# status :: :active | :suspended | :pending
case user.status do
  :active -> allow(user)
  :suspended -> deny(user, :suspended)
  :pending -> deny(user, :pending)
end
```

For a state that carries data, use a tagged tuple — `{:suspended, reason}` — so the payload travels with the state.

Reference: [Elixir — Design anti-patterns: "Boolean obsession"](https://hexdocs.pm/elixir/design-anti-patterns.html)
