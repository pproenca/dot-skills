---
title: Validate untrusted input once at the boundary, then trust it in the core
tags: flow, boundary, changeset, refactor
---

## Validate untrusted input once at the boundary, then trust it in the core

When loose external input (params, JSON, env) flows raw through the whole system, every inner function re-checks types and presence "just in case" — the defensive scaffolding metastasizes. The fix is systemic: parse and validate once at the edge into well-typed data (a changeset into a struct, a parser into a tagged result), and let the core assume valid shapes and pattern-match assertively. "Parse, don't validate" — after the boundary there is nothing left to guard against, so the guards can be deleted from dozens of inner functions. This is a wide refactor, and it is the systemic version of asserting shapes locally.

**Evidence of violation:** raw external input — string-keyed params, decoded JSON, `System.get_env` values — passed beyond the module that received it into core/context functions, with the same presence or type re-checks (`Map.get` on string keys, `is_binary` guards, manual casts) appearing in two or more non-boundary functions along that path. Cite the raw hand-off and at least two downstream re-check sites. PASS: the boundary converts input once into typed data (an `Ecto.Changeset` cast into a struct, an explicit parse function returning `{:ok, struct} | {:error, _}`) and downstream functions match on the struct with no re-checks. N/A: the target has no external-input path (pure library code, no params/JSON/env). A single validation site is where validation belongs — one check at the edge is the PASS shape, never a violation.

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
