---
title: Write consumers for at-least-once delivery
tags: evt, oban, broadway, idempotency
---

## Write consumers for at-least-once delivery

Every durable delivery mechanism on this stack is at-least-once: Oban retries a job that raised *or that succeeded right before the node died without recording completion*; Broadway redelivers messages that were processed but not acked. Duplicate execution is therefore not an edge case — it is the contract. A consumer that inserts without a uniqueness guard, increments a counter, or POSTs to an external API with no idempotency key will, under precisely the crash/deploy conditions the queue exists to survive, double-charge, double-send, and double-count. The consumer body must be safe to run twice: uniqueness enforced by the store, effects keyed by a stable identifier, or writes that set state rather than accumulate it.

**Evidence of violation:** an Oban `perform/1`, Broadway `handle_message`/`handle_batch`, or queue-consumer `handle_info` that performs a non-idempotent effect with no guard — a bare `Repo.insert` with no unique constraint or `on_conflict`, an arithmetic update (`inc:`, read-add-write), or an external POST carrying no idempotency key and preceded by no dedup check. PASS: a unique index plus `on_conflict` handling; effects keyed by job/message id with a processed-marker written atomically with the effect; set-to-value writes; external calls carrying an idempotency key. Oban's `unique` option is enqueue-time dedup only — it does not make `perform` safe to re-run and does not by itself constitute a PASS. N/A: no job workers or message consumers in the target. Carve-out (citable): the effect is naturally idempotent — the reviewer must state *why* re-execution converges (same key, same value) rather than accepting the label.

```elixir
def perform(%Oban.Job{args: %{"order_id" => order_id}}) do
  # Safe to run twice end-to-end: the insert converges on the unique index,
  # and the charge is keyed by order, so a retry returns the first result
  # instead of charging again — no step depends on "this is the first run."
  {:ok, _} = Repo.insert(Invoice.for_order(order_id), on_conflict: :nothing, conflict_target: :order_id)
  PaymentGateway.charge(order_id, idempotency_key: "order-charge-#{order_id}")
end
```

Reference: [Oban — at-least-once execution and uniqueness scope](https://hexdocs.pm/oban/reliable-scheduling.html)
