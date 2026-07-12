---
title: Stream growing collections instead of accumulating them in assigns
tags: stream, memory, collections, pubsub-feeds, pagination
---

## Stream growing collections instead of accumulating them in assigns

A list assign looks free because the first render is. But every assign is resident server memory multiplied by the number of connected sockets, and a collection that *grows* — a bid feed appending from PubSub, a table paginating by concatenation — grows per-socket without bound while change tracking re-diffs the whole list on every insert. Ten thousand spectators on a hot auction each hold their own copy of the same ever-growing bid list. `stream/4` exists precisely for this shape: items are sent to the client and then dropped from the socket, so the server holds nothing per item and each insert ships only the inserted row.

**Evidence of violation:** a list assign rendered in the template that the module also appends to or prepends onto over time — `assign(socket, :bids, [bid | socket.assigns.bids])` (or `++`) in a `handle_info`/`handle_event` clause, including pagination that concatenates pages into one assign. Both legs must be present: rendered collection AND accumulation across messages or events. PASS: the collection lives in a stream (`stream/4` in `mount`/`handle_params`, `stream_insert/4` on updates). N/A: no rendered collection in the target grows after its initial assign — a one-shot list loaded once and replaced wholesale on patch is not this rule's shape. Carve-out (citable): a visible bound in the code that caps accumulation — an `Enum.take(bids, 50)` wrapping every append, a fixed domain enumeration (select options), or a re-fetch with a query `limit` that *replaces* rather than concatenates — cite the bounding expression; "the list stays small in practice" is not evidence.

```elixir
def mount(_params, _session, socket) do
  if connected?(socket), do: Paddle.Auctions.subscribe_bids(socket.assigns.auction)
  {:ok, stream(socket, :bids, Paddle.Auctions.recent_bids(socket.assigns.auction))}
end

def handle_info({:bid_placed, bid}, socket) do
  # The socket keeps no copy; only this row crosses the wire.
  {:noreply, stream_insert(socket, :bids, bid, at: 0, limit: 100)}
end
```

Reference: [Phoenix.LiveView.stream/4 — hexdocs](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#stream/4)
