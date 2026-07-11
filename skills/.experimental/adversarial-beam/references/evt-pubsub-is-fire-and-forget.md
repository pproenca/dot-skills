---
title: Never make a PubSub broadcast the only carrier of a business fact
tags: evt, pubsub, at-most-once, delivery
---

## Never make a PubSub broadcast the only carrier of a business fact

`Phoenix.PubSub` feels like an event bus, so it gets used as one — but it is fire-and-forget, at-most-once delivery with no persistence, no acknowledgment, and no redelivery. A subscriber that is restarting, deploying, or on the wrong side of a netsplit simply never receives the message, and nothing anywhere knows. That is the *right* trade for presentational fan-out: a LiveView that misses an update heals on the next read because the truth lives in the database. It is the wrong trade the moment a broadcast is the only thing standing between a committed fact and a required consequence — the missed message becomes a permanently missed side effect.

**Evidence of violation:** a `Phoenix.PubSub.broadcast` (or `Endpoint.broadcast`) whose subscriber's `handle_info` performs a business-state mutation or external effect (a Repo write, a charge, an email, publishing onward) — and that broadcast is the *only* trigger: no durable job enqueued for the same consequence, no reconciliation process that would produce the effect if the message is lost. PASS: subscriber effects are presentational (socket assigns, pushes, local cache refresh from a durable re-read); or the broadcast is a latency optimization layered over a durable mechanism (an Oban job, an outbox poller) and the reviewer can cite that mechanism. N/A: no PubSub usage in the target. Carve-out (citable): a reconciler or periodic sweep provably covers lost messages — cite the module and what it re-derives; the intention to add one later is the violation.

```elixir
# The consequence rides on a durable job; the broadcast is only the
# "update your screens now" nudge. Losing it costs latency, not truth.
{:ok, order} =
  Repo.transaction(fn ->
    order = Repo.insert!(changeset)
    Oban.insert!(FulfillmentWorker.new(%{order_id: order.id}))
    order
  end)

Phoenix.PubSub.broadcast(MyApp.PubSub, "orders:#{order.customer_id}", {:order_placed, order.id})
```

Reference: [Stephen Bussey — *Real-Time Phoenix* (message delivery guarantees)](https://pragprog.com/titles/sbsockets/real-time-phoenix/)
