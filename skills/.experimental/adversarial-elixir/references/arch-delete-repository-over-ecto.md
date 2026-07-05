---
title: Delete the Repository/DAO wrapper — Ecto is already the data-mapper
tags: arch, ecto, repository, layering
---

## Delete the Repository/DAO wrapper — Ecto is already the data-mapper

Ported from Java/enterprise habits, a `MyApp.Repositories.UserRepository` that wraps `Repo` with `get_user/1`, `insert_user/1`, `list_users/0` pass-throughs is pure indirection. `Ecto.Repo` *is* the Repository pattern — a single boundary to the data store — and the swappability the wrapper pretends to buy (drop-in a different database behind the same interface) never happens in practice. Each wrapper function forwards one call, so the layer adds a file to read, a name to invent, and nothing else. Flatten it: the context calls `Repo` directly.

```elixir
# The Accounts context is the boundary; it talks to Repo directly.
defmodule MyApp.Accounts do
  import Ecto.Query
  alias MyApp.{Repo, Accounts.User}

  def get_user!(id), do: Repo.get!(User, id)

  def list_active_users do
    User |> where(status: :active) |> Repo.all()
  end
end
```

**When NOT to flatten:** a genuinely non-Ecto store (an HTTP API, Redis) deserves a module that owns that access — but name it for the capability, not `SomethingRepository`, and don't mirror it over your Ecto tables.

Reference: [Ecto.Repo — "a repository maps to an underlying data store"](https://hexdocs.pm/ecto/Ecto.Repo.html)
