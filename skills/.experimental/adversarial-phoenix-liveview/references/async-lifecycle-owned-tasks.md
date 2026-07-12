---
title: Start tasks with start_async or a supervisor, never bare spawn
tags: async, task-lifecycle, start-async, supervision
---

## Start tasks with start_async or a supervisor, never bare spawn

A task started raw from a LiveView inherits the wrong lifecycle either way. `Task.async`/`Task.start_link` links: a crash in the task takes down the whole view, and navigation kills the LiveView which kills the linked task mid-flight — work the user believes finished dies with the tab. Unlinked `spawn`/`Task.start` survives but answers to nobody: no supervisor, no shutdown, no visibility. The decision is which lifecycle the work belongs to. Results the UI consumes belong on the view's lifecycle via `start_async`/`assign_async` — crashes arrive as `{:exit, reason}` in `handle_async/3` instead of killing the view, and the task is cancelable with the socket. Work that must complete regardless of the socket — settlement, emails, billing — belongs to a supervisor-owned runner that outlives navigation.

**Evidence of violation:** `spawn/1,3`, `Task.async`, `Task.start`, or `Task.start_link` called inside a LiveView or LiveComponent module. PASS: `start_async`/`assign_async` for results the UI consumes; a supervisor-owned execution (an Oban worker, `Task.Supervisor.start_child`, or any process owned by a supervisor — shape, not brand) for work that must complete without the socket. N/A: the target starts no processes from LiveView modules. Carve-out (citable): `Task.Supervisor.async_nolink` awaited via `handle_info` with explicit `:DOWN`/failure handling predates `start_async` and passes — cite the monitor handling. Bare tasks outside LiveView modules are the sibling gate `adversarial-beam`'s territory; this rule judges only LiveView and LiveComponent modules.

```elixir
def handle_event("close_auction", _params, socket) do
  scope = socket.assigns.current_scope
  auction_id = socket.assigns.auction.id

  # Settlement must finish even if the seller closes the tab —
  # supervisor-owned, detached from this socket's lifetime.
  {:ok, _job} = Settlements.enqueue(scope, auction_id)

  # The status refresh is UI-bound — start_async ties it to the view's
  # lifecycle and delivers a crash as {:exit, reason}, not a takedown.
  {:noreply,
   start_async(socket, :refresh_status, fn ->
     Auctions.get_status(scope, auction_id)
   end)}
end
```

Reference: [Phoenix.LiveView.start_async/3](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#start_async/3)
