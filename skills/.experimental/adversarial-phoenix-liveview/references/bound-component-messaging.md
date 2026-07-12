---
title: Message parent and child through the shared process, not PubSub
tags: bound, live-component, send-update, pubsub
---

## Message parent and child through the shared process, not PubSub

A LiveComponent runs *inside* its parent LiveView's process — there is no network, no other node, no second mailbox between them. Routing a child-to-parent notification through `Phoenix.PubSub` (or bouncing it off the client as a pushed event) replaces a function-call-cheap `send/2` with a broadcast that fans out to every subscriber on the topic, arrives without ordering guarantees relative to the component's own state changes, and forces the parent to subscribe to hear its own child. The docs give the two directions their canonical mechanisms: child to parent is `send(self(), message)` — `self()` *is* the parent's pid — and parent (or anyone) to child is `send_update/3` addressed by module and id.

**Evidence of violation:** a LiveComponent that calls `Phoenix.PubSub.broadcast` (or `Endpoint.broadcast`) to notify its own parent LiveView, a parent that subscribes to a topic whose only publisher is its own child component, or a component-to-parent notification routed through the client (a `push_event` the client re-sends as a new server event). PASS: upward messages use `send(self(), msg)` handled in the parent's `handle_info`; downward or cross-sibling updates use `send_update(Module, id: id, ...)`; cite both call sites. N/A: the target has no component-to-parent or parent-to-component messaging. Carve-out (citable): the broadcast genuinely fans out beyond the parent — cite a second subscriber in another LiveView or process; with no second subscriber the broadcast is intra-process messaging in disguise and the violation stands.

```elixir
# lib/paddle_web/live/auction_live/bid_form_component.ex — child notifies parent
def handle_event("save", %{"bid" => bid_params}, socket) do
  case Paddle.Auctions.place_bid(socket.assigns.scope, socket.assigns.auction, bid_params) do
    {:ok, bid} ->
      send(self(), {__MODULE__, :bid_placed, bid})
      {:noreply, socket}

    {:error, changeset} ->
      {:noreply, assign(socket, :form, to_form(changeset))}
  end
end
```

Reference: [Phoenix.LiveComponent — managing state](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html)
