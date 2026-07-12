---
title: Scope topics to the entity, not one global topic filtered per client
tags: flow, pubsub, topics, fanout
---

## Scope topics to the entity, not one global topic filtered per client

A single `"auctions"` topic that every connected LiveView subscribes to turns topic routing into application code: each socket's `handle_info` receives every event in the system and discards the ones it doesn't render. The discard is not free — every message is a mailbox delivery, a pattern match, and often a guard query, multiplied by every connected socket, for events almost none of them care about. A thousand watchers across a thousand auctions means every bid wakes all thousand processes to update one screen. PubSub already is the filter: embed the discriminator in the topic name — `"auction:#{auction.id}"` for one auction's watchers, `"user_auctions:#{scope.user.id}"` for one seller's dashboard — and each process receives only what it renders. This is the shape the Phoenix scopes guide generates: `subscribe_auctions(scope)` builds the topic from the scope, so narrowing is decided once, in the context.

**Evidence of violation:** a LiveView subscribing to a constant, discriminator-free topic (a bare string with no interpolated entity/scope id) whose `handle_info` then filters — matching an id field against `socket.assigns`, an `if`/`case` discarding events for other entities/users — before applying the event. PASS: subscribed topics interpolate the entity or scope id that the `handle_info` clauses consume unconditionally; or subscription goes through a scope-taking context function (`subscribe_auctions(scope)`) that builds a narrowed topic. N/A: the target subscribes to no PubSub topics. Carve-out (citable): genuinely global data — every subscriber renders every event, with no per-entity filtering in any `handle_info` clause; cite the render path showing the full feed (a site-wide ticker, an ops dashboard). A global topic *with* per-client filtering fails closed.

```elixir
# lib/paddle/auctions.ex — the topic is the filter
def subscribe_auction(%Auction{id: id}) do
  Phoenix.PubSub.subscribe(Paddle.PubSub, "auction:#{id}")
end

# lib/paddle_web/live/auction_live/show.ex
def mount(%{"id" => id}, _session, socket) do
  auction = Auctions.get_auction!(socket.assigns.current_scope, id)
  if connected?(socket), do: Auctions.subscribe_auction(auction)
  {:ok, assign(socket, :auction, auction)}
end

def handle_info({:bid_placed, bid_id}, socket) do
  # no filtering — everything on this topic belongs to this auction
  {:noreply, stream_insert(socket, :bids, Auctions.get_bid!(bid_id), at: 0)}
end
```

Reference: [Phoenix — Scopes guide (scope-narrowed topics in generated contexts)](https://hexdocs.pm/phoenix/scopes.html)
