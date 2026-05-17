---
title: Webhook Events Use a Fixed `{id, object, type, data, created}` Envelope
impact: HIGH
impactDescription: prevents per-event-type parsers in every integrator
tags: ops, webhooks, events, envelope
---

## Webhook Events Use a Fixed `{id, object, type, data, created}` Envelope

Every webhook event is delivered as the same envelope shape: `id` (unique event ID, `evt_*`), `object: "event"`, `type` (the event type, see [`ops-webhook-event-naming`](ops-webhook-event-naming.md)), `created` (Unix seconds), `livemode`, `data: { object: <the actual resource> }`, `request: { id, idempotency_key }` (which API request triggered this event, if any), and `api_version` (the API version the payload is formatted as). One envelope shape lets integrators write a single webhook parser that branches on `type`, instead of per-event-type parsers.

The `data.object` field is the affected resource — a charge, a payment intent, an invoice — and follows the same shape that endpoint would return. This means an integrator's existing model classes (Charge, PaymentIntent) can be reused to deserialise webhook payloads without parallel webhook-specific types.

**Incorrect (event payloads vary per type — no shared envelope):**

```json
// One event type:
{ "kind": "charge_succeeded", "charge_id": "ch_X", "amount": 2000 }

// Another event type:
{ "event": "customer.created", "customer": { "id": "cus_X", ... } }

// Another:
{ "type": "InvoicePaid", "invoiceId": "in_X", "paidAt": "2026-05-17T10:30:00Z" }
```

```text
// Three different envelope shapes, three field-name conventions, three timestamp formats.
// Integrator writes per-type parsers; generic webhook dispatcher impossible.
// Adding a new event type requires SDK updates to add yet another parser.
```

**Correct (single envelope shape, type field discriminates the resource inside `data.object`):**

```json
POST https://example.com/webhook
Content-Type: application/json
Stripe-Signature: t=1747699200,v1=<hmac>...

{
  "id": "evt_1NkLBxLkdIwHu7ix2vQHnK1Y",
  "object": "event",
  "type": "charge.succeeded",
  "api_version": "2024-10-28",
  "created": 1747699200,
  "livemode": true,
  "data": {
    "object": {
      "id": "ch_3MqZlPLkdIwHu7ix0slN3S9y",
      "object": "charge",
      "amount": 2000,
      "currency": "usd",
      "status": "succeeded",
      "customer": "cus_NffrFeUfNV2Hib",
      "metadata": { "order_id": "6735" }
    }
  },
  "request": {
    "id": "req_abc123",
    "idempotency_key": "4ab9c8a1-7e3d-4c8f-9b21-7d1f3c5e8a91"
  }
}
```

```text
// Same envelope for every event type — `charge.succeeded`, `customer.created`, `invoice.paid`, ...
// `data.object` IS the resource in its canonical shape — reuse existing model classes.
// `request.idempotency_key` lets you correlate the webhook back to the originating API call.
// `api_version` pins the payload shape — see "Event payloads are immutable" below.
```

**The required envelope fields:**

| Field | Type | Purpose |
|-------|------|---------|
| `id` | string (`evt_*`) | Unique event ID, used for deduplication |
| `object` | string (always `"event"`) | Self-describing discriminator |
| `type` | string | The event type (see [`ops-webhook-event-naming`](ops-webhook-event-naming.md)) |
| `created` | integer | Unix seconds when the event happened |
| `livemode` | boolean | Test mode vs live |
| `data.object` | object | The affected resource in its canonical shape |
| `request.id` | string \| null | The API request that triggered the event (if any) |
| `request.idempotency_key` | string \| null | The idempotency key of the originating request |
| `api_version` | string | The version the payload is formatted as (see "Event payloads are immutable") |

**Event payloads are immutable to the API version pinned at the time of delivery.** When an account upgrades its API version, *new* events fire with the new payload shape, but historical events keep their original shape. Endpoints can also be pinned to a different version explicitly:

```text
POST /v1/webhook_endpoints
url=https://example.com/webhook&api_version=2025-04-30
```

```text
// This endpoint receives events formatted as 2025-04-30 regardless of the account's pin.
// Lets integrators test a new API version's webhook payload before upgrading account-wide.
```

**Adding new fields to webhook payloads is backwards-compatible** if integrators tolerate unknown fields — see [`ver-tolerate-unknown`](ver-tolerate-unknown.md). Adding new event types is also backwards-compatible.

**For event lifecycle changes** (deletes, terminal states), include `previous_attributes` showing the fields that changed:

```json
{
  "type": "charge.refunded",
  "data": {
    "object": { /* charge after refund */ },
    "previous_attributes": { "refunded": false, "amount_refunded": 0 }
  }
}
```

Lets handlers compute "what changed" without keeping their own prior-state snapshot.

Reference: [Stripe webhooks](https://docs.stripe.com/webhooks), [Stripe Event object](https://docs.stripe.com/api/events/object)
