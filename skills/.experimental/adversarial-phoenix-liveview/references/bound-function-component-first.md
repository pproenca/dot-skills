---
title: Use function components unless the component owns state and events
tags: bound, live-component, function-component, organization
---

## Use function components unless the component owns state and events

A LiveComponent is a stateful unit with its own mount/update/render lifecycle, its own assigns held in the parent's process memory, and its own event-routing rules (`phx-target`). Paying that cost for markup reuse is the wrong default the docs name explicitly: "prefer function components over live components as they are a simpler abstraction with a smaller surface area" and "Avoid using LiveComponents merely for code organization purposes." A LiveComponent that defines no `handle_event` and keeps no state of its own is a function component wearing lifecycle callbacks — it adds `id` bookkeeping, `send_update` coupling, and change-tracking indirection while doing nothing a plain `attr`/`slot` component would not.

**Evidence of violation:** a module with `use Phoenix.LiveComponent` that defines no `handle_event/3` and holds no component-local state — its `update/2` is absent or only merges the parent's assigns (no assigns originate inside the component). PASS: the LiveComponent defines `handle_event/3`, or its `update/2`/`mount/1` creates state the parent does not pass in (a local form, a toggle, an async result); cite the callback. Also PASS: markup extraction done as `Phoenix.Component` function components. N/A: the target adds no components. Carve-out (citable): the component exists as the documented `send_update/3` target for a third party (a parent or sibling pushes updates into it by id) — cite the `send_update` call site; without one, statefulness is unused and the violation stands.

```elixir
# lib/paddle_web/components/auction_components.ex — markup reuse is a function component
attr :auction, Paddle.Auctions.Auction, required: true
attr :highest_bid, :integer, required: true

def auction_card(assigns) do
  ~H"""
  <div class="auction-card">
    <h3>{@auction.title}</h3>
    <p>Current bid: {@highest_bid}</p>
  </div>
  """
end
```

Reference: [Phoenix.LiveComponent — when to use](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html)
