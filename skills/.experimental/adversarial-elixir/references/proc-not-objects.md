---
title: Stop modeling each entity as a process — processes are not objects
tags: proc, genserver, state, refactor
---

## Stop modeling each entity as a process — processes are not objects

Spawning one GenServer per `User`/`Order`/`Product` to "hold" that record is the deepest paradigm betrayal: it treats a process as an object with encapsulated fields. A BEAM process is a unit of *concurrency, isolation, and resource ownership* — not a container for a row. Modeling entities this way duplicates the source of truth (now the DB and the process disagree), forces a lookup-and-message dance for every read, serializes access per entity, and loses all the data on restart. State lives in the database (or ETS as a cache); behavior lives in pure context functions.

**Evidence of violation:** a GenServer/Agent started per persisted domain record — `start_link` keyed by a record id, process state holding fields that also live in a database row (or that are lost on restart with no recovery path), reads answered from process state instead of the store. PASS: entity state is read from and written to the database/ETS through context functions, with no per-entity process. N/A: the target starts no per-entity processes. Carve-out (citable): the entity has a genuinely independent runtime lifecycle — a live game session, an open device/websocket connection, an in-flight state machine — where the process *is* the running thing; cite what makes the lifecycle runtime-bound (timers, connection ownership, continuous interaction), not just "it's convenient to cache". A carve-out asserted without that evidence fails closed.

```elixir
# No per-user process. State in the DB, behavior in functions.
defmodule MyApp.Accounts do
  def suspend(%User{} = user), do:
    user |> User.changeset(%{status: :suspended}) |> Repo.update()
end
```

**When an entity DOES deserve a process:** it has a genuinely independent runtime lifecycle — a live game session, an open device/websocket connection, an in-flight state machine — where the process *is* the running thing, not a cache of a row. Then supervise it and key it through a `Registry`.

Reference: [Elixir — Process anti-patterns: "Code organization by process"](https://hexdocs.pm/elixir/process-anti-patterns.html)
