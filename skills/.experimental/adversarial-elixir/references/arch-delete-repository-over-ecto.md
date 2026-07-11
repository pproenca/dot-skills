---
title: Delete the Repository/DAO wrapper — Ecto is already the data-mapper
tags: arch, ecto, repository, layering
---

## Delete the Repository/DAO wrapper — Ecto is already the data-mapper

Ported from Java/enterprise habits, a `MyApp.Repositories.UserRepository` that wraps `Repo` with `get_user/1`, `insert_user/1`, `list_users/0` pass-throughs is pure indirection. `Ecto.Repo` *is* the Repository pattern — a single boundary to the data store — and the swappability the wrapper pretends to buy (drop-in a different database behind the same interface) never happens in practice. Each wrapper function forwards one call, so the layer adds a file to read, a name to invent, and nothing else. Flatten it: the context calls `Repo` directly.

**Evidence of violation:** a module named `*Repository`, `*Repo` (other than the app's `Ecto.Repo` module itself), or `*DAO` — or documented as "the repository for X" — whose public functions each forward to a single `Repo.get/insert/update/delete/all/one` call (adding at most an argument reshuffle or a query the caller could own). PASS: contexts call `Repo` directly, or the wrapper module does not exist. N/A: the target has no Ecto dependency. Carve-out (citable): the module fronts a genuinely non-Ecto store (HTTP API, Redis, ETS) — the non-Ecto access must be visible in its body; a wrapper that mirrors Ecto tables fails regardless of its name. A carve-out asserted without that evidence fails closed.

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
