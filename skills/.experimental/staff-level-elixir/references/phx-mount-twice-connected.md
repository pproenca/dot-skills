---
title: Gate LiveView side effects on connected?/1 — mount runs twice
tags: phx, liveview, mount, connected
---

## Gate LiveView side effects on connected?/1 — mount runs twice

A LiveView's `mount/3` is invoked **twice**: once for the initial static HTTP render (disconnected) and again when the client establishes the WebSocket (connected). Code that assumes a single mount doubles side effects — two `Phoenix.PubSub.subscribe` calls, two timers, two analytics events — and wastes work on the disconnected pass that the user may never upgrade from. Guard anything stateful or expensive with `connected?(socket)`: subscriptions, `:timer.send_interval`, presence tracking, and heavy queries you only want once the live session is real. Data needed for the first paint should still load on both passes (so the static render isn't empty).

```elixir
def mount(%{"room_id" => room_id}, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(MyApp.PubSub, "room:#{room_id}")
    :timer.send_interval(30_000, self(), :refresh_presence)
  end

  # Runs on both passes so the initial static render has content.
  {:ok, assign(socket, room: Chat.get_room!(room_id))}
end
```

Reference: [Phoenix.LiveView — `connected?/1`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#connected?/1)
