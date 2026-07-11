---
title: Enqueue side-effect jobs inside the transaction that creates the fact
tags: evt, oban, outbox, transaction
---

## Enqueue side-effect jobs inside the transaction that creates the fact

Triggering a required side effect *next to* a transaction instead of *inside* it creates two failure windows, one on each side of the commit. Trigger after commit, and a crash or deploy between commit and trigger loses the effect — the order exists, the fulfillment never starts. Trigger before or during via a message (`Task.start`, `send`, a broadcast), and a rollback produces a ghost effect for a fact that never happened. The BEAM's process machinery cannot fix this; the atomicity has to come from the store. An Oban job is a database row, so `Ecto.Multi` (or `Oban.insert!/2` inside `Repo.transaction`) commits the fact and the obligation atomically — the transactional-outbox pattern with the queue already inside your database.

**Evidence of violation:** a correctness-relevant side effect (external API call, email/notification, payment, publishing an event onward) launched via `Task.start`/`spawn`/`send`/`cast`/PubSub broadcast immediately after — or from inside — a `Repo.transaction`/`Ecto.Multi` that records the triggering fact, with no job row or outbox record committed in that same transaction. PASS: the job/outbox insert participates in the transaction (`Ecto.Multi` + `Oban.insert/3-4`, or an outbox table written in-tx with a relay); or the effect is re-derived by a reconciler the reviewer can cite. N/A: the target pairs no database transactions with side effects. Carve-out (citable): the effect is best-effort by design — a non-essential notification whose loss is explicitly acceptable — cite the statement or the product behavior that tolerates the loss.

```elixir
# One commit, two rows: the order and the obligation to fulfill it.
# There is no instant where one exists without the other.
Ecto.Multi.new()
|> Ecto.Multi.insert(:order, changeset)
|> Oban.insert(:fulfillment, fn %{order: order} ->
  FulfillmentWorker.new(%{order_id: order.id})
end)
|> Repo.transaction()
```

Reference: [Oban — transactional job insertion and reliability](https://hexdocs.pm/oban/Oban.html#insert/3)
