---
title: Guard stateful mount work behind connected?
tags: state, connected, mount, subscriptions, timers
---

## Guard stateful mount work behind connected?

`mount/3` runs twice: once in the HTTP request process for the disconnected render, then again in the LiveView process when the socket connects. The first process serves the static page and dies. Subscriptions taken there are wasted work bound to a corpse; `:timer.send_interval/3` targets a process about to exit; `Presence.track` registers a phantom that joins and immediately leaves, double-firing every presence listener. The docs are direct: "Use `connected?/1` to conditionally perform stateful work, such as subscribing to pubsub topics, sending messages, etc." The wrong assumption is that mount means "the view started" — it means "a render is needed", and only the connected one is the live process.

**Evidence of violation:** any of `Phoenix.PubSub.subscribe`, `Endpoint.subscribe`, a context `subscribe_*` call, `:timer.send_interval`, `Process.send_after(self(), ...)`, or `Presence.track` executed in `mount/3` outside an `if connected?(socket)` (or equivalent) guard. PASS: each such call sits behind `connected?(socket)`. Exempt by design: `assign_async`/`start_async` — the docs state the task "is only started when the socket is connected", so they self-guard. N/A: `mount/3` performs none of the enumerated stateful work. There is no carve-out for "the double-run is harmless" — the disconnected process's exit makes the claim untestable from the artifact; fail closed.

```elixir
def mount(%{"id" => id}, _session, socket) do
  auction = Paddle.Auctions.get_auction!(socket.assigns.current_scope, id)

  if connected?(socket) do
    Paddle.Auctions.subscribe(auction)
    :timer.send_interval(1_000, self(), :tick)
  end

  {:ok, assign(socket, :auction, auction)}
end
```

Reference: [Phoenix.LiveView.connected?/1](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#connected?/1)
