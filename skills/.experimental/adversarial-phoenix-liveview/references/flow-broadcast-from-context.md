---
title: Broadcast domain events beside the write, not from the LiveView
tags: flow, pubsub, contexts, broadcast-placement
---

## Broadcast domain events beside the write, not from the LiveView

A broadcast emitted from a `handle_event` callback announces the write only when *that* LiveView performs it. Every other path to the same write — an Oban job settling an auction, a seed script, an admin controller, a second LiveView added next quarter — calls the context function, succeeds, and emits nothing; every subscribed screen silently goes stale, and no test of the LiveView catches it because the LiveView's own path still works. The context function that performs the write is the one place every writer already passes through, so the broadcast lives there: `Paddle.Auctions.place_bid/2` broadcasts `bid_placed` after its own successful insert, and the LiveView is only ever a subscriber. This is the convention `mix phx.gen.live` generates (context owns `subscribe_*` and `broadcast_*`) and the shape McCord demonstrates in LiveBeats — convention-backed rather than a hexdocs MUST, but the staleness failure it prevents is mechanical.

**Evidence of violation:** a `Phoenix.PubSub.broadcast`/`broadcast!` or `Endpoint.broadcast` call inside a `*Web.*Live` module (a LiveView or LiveComponent under `lib/*_web/`) whose message announces a domain write (a created/updated/deleted entity), where the write itself is a context function with any other caller — or with a public context API that permits one. PASS: broadcasts of domain events appear only in context modules (or a module the context delegates to), colocated with or downstream of the successful write; LiveViews contain `subscribe`/`handle_info` only. N/A: the target broadcasts no domain events. Carve-out (citable): ephemeral UI-only signals with no corresponding domain write — a "user is typing" ping, a cursor position — may broadcast from the LiveView; cite the absence of any persisted write in the event's path. A domain write claimed as "UI-only" fails closed.

```elixir
# lib/paddle/auctions.ex — every writer emits, because the write emits
def place_bid(%Scope{} = scope, %Auction{} = auction, attrs) do
  with {:ok, bid} <- create_bid(scope, auction, attrs) do
    Phoenix.PubSub.broadcast(
      Paddle.PubSub,
      "auction:#{auction.id}",
      {:bid_placed, bid.id}
    )

    {:ok, bid}
  end
end
```

Reference: [Phoenix — Scopes guide (generated context subscribe/broadcast convention)](https://hexdocs.pm/phoenix/scopes.html), [Fly.io — LiveBeats (broadcast from business logic)](https://fly.io/blog/livebeats/)
