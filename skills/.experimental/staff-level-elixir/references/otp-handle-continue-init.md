---
title: Move heavy init work into handle_continue, not init/1
tags: otp, genserver, handle-continue, startup
---

## Move heavy init work into handle_continue, not init/1

`init/1` runs **synchronously inside the supervisor's start sequence**: the supervisor blocks until it returns, and so does every sibling that starts after it. The common wrong default is to load data, hit the database, or call an external service directly in `init/1` — that stalls the whole supervision tree on boot, and if the call is slow it can trip the supervisor's start timeout and crash the app on startup. Return the minimal state from `init/1` and hand the expensive setup to `handle_continue/2` via `{:ok, state, {:continue, :load}}`: the process is already started and supervised, and the heavy work happens in its own message loop without blocking anyone.

```elixir
def init(opts) do
  # Return fast — just enough state to exist. Defer the expensive load.
  {:ok, %{table: opts[:table], data: nil}, {:continue, :load}}
end

def handle_continue(:load, state) do
  # Runs after init returns, off the supervisor's critical path.
  {:noreply, %{state | data: Repo.all(from r in state.table)}}
end
```

Reference: [Elixir — `GenServer.handle_continue/2`](https://hexdocs.pm/elixir/GenServer.html#c:handle_continue/2)
