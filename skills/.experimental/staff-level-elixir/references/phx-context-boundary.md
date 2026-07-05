---
title: Call contexts from the web layer, never Repo or schemas directly
tags: phx, contexts, boundaries, architecture
---

## Call contexts from the web layer, never Repo or schemas directly

The convenient shortcut is to `Repo.get`, build changesets, and run queries straight from a controller or LiveView. It couples your transport layer to the database schema, scatters business rules across web modules, and makes the logic impossible to test or reuse without a connection. Phoenix contexts exist to be that boundary: the web layer calls a named domain function (`Accounts.update_user/2`), and everything about *how* it's stored — queries, changesets, transactions, `Repo` — lives behind it. Controllers and LiveViews should read as orchestration of context calls plus rendering, with no `Repo` or `Ecto.Query` in sight.

```elixir
# Context owns the data access and the rules.
defmodule MyApp.Accounts do
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end
end

# Controller orchestrates; it never touches Repo or the schema's internals.
defmodule MyAppWeb.UserController do
  def update(conn, %{"id" => id, "user" => params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, params) do
      {:ok, user} -> redirect(conn, to: ~p"/users/#{user}")
      {:error, changeset} -> render(conn, :edit, changeset: changeset)
    end
  end
end
```

Reference: [Phoenix — Contexts guide](https://hexdocs.pm/phoenix/contexts.html)
