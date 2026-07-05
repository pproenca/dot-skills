---
title: Stop modeling each entity as a process — processes are not objects
tags: proc, genserver, state, refactor
---

## Stop modeling each entity as a process — processes are not objects

Spawning one GenServer per `User`/`Order`/`Product` to "hold" that record is the deepest paradigm betrayal: it treats a process as an object with encapsulated fields. A BEAM process is a unit of *concurrency, isolation, and resource ownership* — not a container for a row. Modeling entities this way duplicates the source of truth (now the DB and the process disagree), forces a lookup-and-message dance for every read, serializes access per entity, and loses all the data on restart. State lives in the database (or ETS as a cache); behavior lives in pure context functions.

```elixir
# No per-user process. State in the DB, behavior in functions.
defmodule MyApp.Accounts do
  def suspend(%User{} = user), do:
    user |> User.changeset(%{status: :suspended}) |> Repo.update()
end
```

**When an entity DOES deserve a process:** it has a genuinely independent runtime lifecycle — a live game session, an open device/websocket connection, an in-flight state machine — where the process *is* the running thing, not a cache of a row. Then supervise it and key it through a `Registry`.

Reference: [Elixir — Process anti-patterns: "Code organization by process"](https://hexdocs.pm/elixir/process-anti-patterns.html)
