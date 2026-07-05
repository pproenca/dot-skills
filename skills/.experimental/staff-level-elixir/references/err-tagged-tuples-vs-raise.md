---
title: Return tagged tuples for expected failures, raise for invariant violations
tags: err, tagged-tuples, exceptions, api-design
---

## Return tagged tuples for expected failures, raise for invariant violations

The wrong default — carried over from exception-first languages — is to `raise` whenever something goes wrong. In Elixir, exceptions are for *unexpected* conditions: broken invariants, programmer errors, "this can never happen." Anything the caller can reasonably anticipate and act on — not found, invalid input, upstream unavailable — is a normal outcome and belongs in the return value as `{:ok, value}` / `{:error, reason}`, where `reason` is a matchable term, not a human string. Provide a `!` variant that raises for callers who treat failure as fatal. Raising for expected failure forces callers into `try/rescue` for ordinary control flow and couples them to your exception structs.

```elixir
defmodule Accounts do
  # Expected outcome — caller decides what to do with each branch.
  def fetch_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  # Bang variant for callers who consider absence a bug worth crashing on.
  def fetch_user!(id) do
    case fetch_user(id) do
      {:ok, user} -> user
      {:error, :not_found} -> raise Ecto.NoResultsError, queryable: User
    end
  end
end
```

Reference: [Elixir — Design anti-patterns: "Exceptions for control-flow"](https://hexdocs.pm/elixir/design-anti-patterns.html#exceptions-for-control-flow)
