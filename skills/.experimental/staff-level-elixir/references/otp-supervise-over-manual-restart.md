---
title: Supervise processes with child specs instead of restarting by hand
tags: otp, supervisor, dynamic-supervisor, registry
---

## Supervise processes with child specs instead of restarting by hand

The wrong default is to `spawn`/`start_link` worker processes ad hoc and write logic to detect crashes and restart them. That reinvents — badly — what a supervisor already does: define children as specs under a supervision strategy and the runtime restarts them with fresh state and correct backoff. For a fixed set of workers, put them in the application's supervision tree. For a variable population created at runtime (one process per game, per upload, per connection), use `DynamicSupervisor` to start children on demand and `Registry` to address them by a business key instead of hand-rolling a name table. Manually managed processes leak on crash, restart in tight loops, and shut down in the wrong order.

```elixir
# Runtime-created, individually addressable workers — supervised, not hand-managed.
defmodule Uploads.Supervisor do
  use DynamicSupervisor

  def start_link(_), do: DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)

  @impl true
  def init(_), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_upload(upload_id) do
    spec = {Uploads.Worker, upload_id: upload_id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end

defmodule Uploads.Worker do
  use GenServer

  # Register under the business key so callers look it up via the Registry,
  # and a crash-restart re-registers automatically.
  def start_link(opts) do
    id = Keyword.fetch!(opts, :upload_id)
    GenServer.start_link(__MODULE__, opts, name: {:via, Registry, {Uploads.Registry, id}})
  end

  # ...
end
```

Reference: [Elixir — `DynamicSupervisor`](https://hexdocs.pm/elixir/DynamicSupervisor.html)
