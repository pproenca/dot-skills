---
title: Express Non-CRUD Actions as Imperative Sub-Paths
impact: CRITICAL
impactDescription: prevents overloaded update endpoints and ambiguous idempotency scope
tags: url, actions, verbs, rest
---

## Express Non-CRUD Actions as Imperative Sub-Paths

For operations that don't fit CRUD — capturing a payment intent, cancelling a subscription, finalising an invoice, attaching a payment method — append an imperative verb as a sub-path of the resource URL: `POST /v1/payment_intents/{id}/capture`, `POST /v1/subscriptions/{id}/cancel`, `POST /v1/invoices/{id}/finalize`, `POST /v1/payment_methods/{id}/attach`. The verb is snake_case and uses present-tense imperative form (`capture`, `cancel`, `finalize`, `attach`, `detach`, `confirm`, `refund`).

This pattern preserves URL predictability (the resource type is in the path), gives each action its own URL for idempotency keys and rate-limiting, and avoids the contortion of expressing actions as fake sub-resources (`POST /v1/payment_intents/{id}/captures` — plural collection of "captures"?) or as state transitions in the update body (`POST /v1/payment_intents/{id}` with `status=captured` — overloads update semantics and hides intent).

**Incorrect (action as state-machine update):**

```text
POST /v1/subscriptions/sub_X
Content-Type: application/x-www-form-urlencoded

status=canceled
```

```text
// "Update the status to canceled" — but status isn't really a writable field.
// Side effects (refund proration, cancel future invoices) hidden behind a generic update.
// No dedicated URL for rate-limiting or idempotency scoping.
```

**Incorrect (action as a fake plural sub-resource):**

```text
POST /v1/payment_intents/pi_X/captures
```

```text
// "Captures" isn't a resource — there's at most one capture per PaymentIntent.
// Listing would be pointless; pluralising muddles the model.
```

**Correct (imperative verb sub-path):**

```text
POST /v1/payment_intents/pi_X/capture
POST /v1/subscriptions/sub_X/cancel
POST /v1/invoices/in_X/finalize
POST /v1/payment_methods/pm_X/attach
POST /v1/payment_methods/pm_X/detach
```

```text
// Reads as an English sentence: "POST capture on payment intent pi_X."
// Each action has its own URL for idempotency, rate limits, and metrics.
// Discoverable in API listings — actions appear grouped under their resource.
```

**Naming the action verb:**
- Snake_case (`finalize`, not `Finalize` or `finalize-invoice`)
- Present-tense imperative (`cancel`, not `cancellation` or `canceled`)
- Verb alone (no object): `capture` on `/payment_intents/{id}` — the object is the resource in the path
- Pair attach/detach, cancel/uncancel where reversal is supported

Reference: [Stripe PaymentIntent.capture](https://docs.stripe.com/api/payment_intents/capture), [Stripe Subscription.cancel](https://docs.stripe.com/api/subscriptions/cancel)
