---
title: Persist re-fetched truth, not broadcast snapshots
tags: evt, pubsub, stale-data, fat-events
---

## Persist re-fetched truth, not broadcast snapshots

A "fat event" — a broadcast carrying the full entity struct — is convenient right up until two of them race. Each subscriber applies whichever snapshot arrives last, arrival order differs per subscriber and per node, and the snapshot was already stale the moment it left the producer (another writer may have committed between the read and the receive). Displaying the payload of *this* event is fine — "order 42 shipped" renders the event itself. Writing the payload into a durable store or authoritative cache *as the entity's current state* is the violation: the subscriber has promoted an unordered, at-most-once snapshot to a source of truth. Broadcast the identifier (plus event-specific display data), and let any consumer that needs current state re-fetch it from the store that serializes writes.

**Evidence of violation:** a subscriber (`handle_info` on a PubSub/channel message) that writes the received payload struct into a durable or shared authoritative store — a `Repo` update built from payload fields, an `:ets.insert` into a cache other code reads as current state — without a version/staleness check. PASS: the subscriber re-fetches by id before writing (`Repo.get`, a context call); or the payload write is guarded by a version comparison (see the cross-source-ordering rule); or the payload is used only to render/announce the event itself. N/A: no subscriber persists broadcast data in the target. Carve-out (citable): the broadcast *is* the system of record — a genuinely event-sourced flow where the event log is the store and consumers are projections with sequence tracking — cite the log and the sequence handling; a PubSub topic is not an event log.

```elixir
def handle_info({:order_updated, order_id}, socket) do
  # The event says "something changed"; the database says what is true now.
  # Re-fetching by id is immune to broadcast reordering and staleness.
  {:noreply, assign(socket, :order, Orders.get_order!(order_id))}
end
```

Reference: [Stephen Bussey — *Real-Time Phoenix* (designing channel/PubSub payloads)](https://pragprog.com/titles/sbsockets/real-time-phoenix/)
