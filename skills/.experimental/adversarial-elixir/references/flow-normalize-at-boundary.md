---
title: Validate untrusted input once at the boundary, then trust it in the core
tags: flow, boundary, changeset, refactor
---

## Validate untrusted input once at the boundary, then trust it in the core

When loose external input (params, JSON, env) flows raw through the whole system, every inner function re-checks types and presence "just in case" — the defensive scaffolding metastasizes. The fix is systemic: parse and validate once at the edge into well-typed data (a changeset into a struct, a parser into a tagged result), and let the core assume valid shapes and pattern-match assertively. "Parse, don't validate" — after the boundary there is nothing left to guard against, so the guards can be deleted from dozens of inner functions. This is a wide refactor, and it is the systemic version of asserting shapes locally.

```elixir
# Boundary: turn params into a validated struct once.
def create_user(params) do
  %User{}
  |> User.changeset(params)         # casts + validates here, once
  |> Repo.insert()
end

# Core: every function downstream receives a valid %User{} and never re-checks.
def welcome(%User{email: email, name: name}), do: Mailer.welcome(email, name)
```

Reference: [Ecto.Changeset — cast and validate external data at the boundary](https://hexdocs.pm/ecto/Ecto.Changeset.html)
