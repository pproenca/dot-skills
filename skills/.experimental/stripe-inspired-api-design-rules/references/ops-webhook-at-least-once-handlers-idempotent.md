---
title: Document At-Least-Once Delivery; Handlers Must Dedupe on `event.id`
impact: HIGH
impactDescription: prevents double-processing under retries and parallel delivery
tags: ops, webhooks, idempotency, delivery
---

## Document At-Least-Once Delivery; Handlers Must Dedupe on `event.id`

Webhook delivery is **at-least-once with no ordering guarantee**. The platform retries failed deliveries (Stripe retries for up to 3 days with exponential backoff in live mode), so the same event may arrive multiple times. The platform may also deliver events out of order or in parallel. Handlers must therefore (a) dedupe on `event.id` before processing, and (b) be tolerant of out-of-order delivery — `charge.succeeded` may arrive after `charge.refunded` in degenerate cases.

This contract is the webhook equivalent of [`idem-key-header`](idem-key-header.md). Without explicit dedupe, retries cause double-fulfilment (ship the same order twice), double-refunds (credit the customer twice), and inconsistent counters. The pattern is straightforward — insert `event.id` into a unique-constrained table; ON CONFLICT, return early — and goes a long way toward making webhook handlers correct under real-world delivery semantics.

**Incorrect (handler assumes exactly-once delivery):**

```python
@app.post('/webhook')
def handle_webhook(event):
    if event['type'] == 'charge.succeeded':
        charge = event['data']['object']
        fulfill_order(charge['metadata']['order_id'])  # ships the product
        send_receipt_email(charge['customer'])         # sends an email
        increment_revenue_counter(charge['amount'])    # bumps a metric
```

```text
// Stripe retries on a transient network blip → fulfill_order runs twice → ship two products.
// send_receipt_email runs twice → customer gets two receipts.
// increment_revenue_counter runs twice → revenue is double-counted.
// Customer complains, support investigates, root cause is "no dedupe in webhook handler".
```

**Incorrect (dedupe by re-querying the resource — has race conditions):**

```python
@app.post('/webhook')
def handle_webhook(event):
    if event['type'] == 'charge.succeeded':
        charge = event['data']['object']
        order = db.get_order(charge['metadata']['order_id'])
        if order.status != 'shipped':  # "dedupe" by checking order state
            fulfill_order(order.id)
```

```text
// Two parallel webhook deliveries both read `status != 'shipped'` simultaneously.
// Both proceed to fulfill_order — two shipments.
// Resource-state-based dedupe needs row-level locking; almost always implemented wrong.
```

**Correct (dedupe on event.id with a unique constraint):**

```sql
CREATE TABLE processed_webhook_events (
  event_id VARCHAR(255) PRIMARY KEY,
  event_type VARCHAR(255) NOT NULL,
  processed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- Optional: store the processed result for replay-safe diagnostics
  result JSONB
);
```

```python
@app.post('/webhook')
def handle_webhook(raw_body: bytes, signature: str):
    event = verify_webhook(raw_body, signature)  # see ops-webhook-signature

    try:
        # Claim the event ID — fails on conflict if we've seen it before
        db.execute(
            "INSERT INTO processed_webhook_events (event_id, event_type) VALUES ($1, $2)",
            event['id'], event['type']
        )
    except UniqueViolation:
        # We've already processed this event; ack the retry and exit
        return Response(status=200)

    # First time seeing this event — process it
    if event['type'] == 'charge.succeeded':
        process_charge_succeeded(event['data']['object'])

    return Response(status=200)
```

```text
// First delivery: INSERT succeeds, handler runs.
// Retry delivery: INSERT fails with UniqueViolation, handler returns 200 without re-running.
// Parallel deliveries: one INSERT wins via the unique constraint; the other returns early.
// Three deliveries, one shipment, one email, one revenue increment. Correct.
```

**Acknowledge fast, process async** for handlers that do expensive work:

```python
@app.post('/webhook')
def handle_webhook(raw_body: bytes, signature: str):
    event = verify_webhook(raw_body, signature)

    try:
        db.execute(
            "INSERT INTO processed_webhook_events (event_id, event_type) VALUES ($1, $2)",
            event['id'], event['type']
        )
    except UniqueViolation:
        return Response(status=200)

    # Enqueue for async processing — return 200 to the platform immediately
    job_queue.enqueue(process_event_job, event['id'], event)

    return Response(status=200)
```

```text
// Webhook handler returns in < 100ms — platform doesn't time out and retry.
// Expensive work happens in a worker that can fail and retry independently.
// Worker uses the same event_id-based dedupe pattern internally if needed.
```

**Out-of-order delivery — defensive patterns:**

| Scenario | Defensive handling |
|----------|-------------------|
| `charge.refunded` before `charge.succeeded` | Fetch the canonical charge state via `GET /v1/charges/{id}` and process the *current* state, not the event payload |
| Multiple terminal events for the same resource (`succeeded` then `failed` for the same payment intent) | Use the latest event's `created` timestamp as a tiebreaker; process the most recent state |
| Same event type, different sequence numbers | Look up the resource's current state on the API rather than trusting payload order |

**For ordering-sensitive workflows**, treat the event as a notification ("something changed on this resource") and re-read the canonical state via the API. The webhook payload is a hint; the API is the source of truth.

**Document the delivery contract** prominently in webhook docs:

> **Delivery semantics:** webhook deliveries are at-least-once with no ordering guarantee. The same event may be delivered multiple times. Handlers must dedupe on `event.id` and tolerate out-of-order delivery.
>
> **Retry policy:** failed deliveries (non-2xx response, timeout, connection error) are retried with exponential backoff for up to 3 days in live mode. Deliveries that consistently fail produce a notification in the dashboard.
>
> **Timeout:** webhook endpoints must respond within 30 seconds; longer responses are treated as failures and retried.

Reference: [Stripe webhook best practices](https://docs.stripe.com/webhooks/best-practices)
