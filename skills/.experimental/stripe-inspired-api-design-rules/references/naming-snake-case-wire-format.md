---
title: Use snake_case for All Wire Identifiers
impact: HIGH
impactDescription: prevents casing inconsistency from forcing breaking renames later
tags: naming, snake-case, wire-format, sdk
---

## Use snake_case for All Wire Identifiers

Every identifier on the wire is `lowercase_snake_case`: field names (`payment_method`, `billing_details`, `amount_captured`), enum values (`requires_action`, `card_declined`), event types (`payment_intent.succeeded`), error codes (`incorrect_cvc`), action endpoint verbs (`/capture`, `/cancel`). The rule applies uniformly across JSON response payloads, form-encoded request fields, query string parameters, event names, and error codes.

SDK clients can map snake_case to their language's preferred convention (camelCase in TypeScript/JS/Java, PascalCase for types) at the SDK layer — that's a one-time mapping the SDK owns. But the wire format is the contract every consumer reads; mixing casings on the wire creates a permanent compatibility tax that ripples through every integration.

**Incorrect (camelCase on the wire):**

```json
{
  "slotHoldId": "sh_abc",
  "clientSecret": "cs_...",
  "stripeCheckoutSessionId": "cs_test_123",
  "cancelledBy": "customer"
}
```

```text
// Inconsistent with the rest of the API surface (query params often end up snake_case anyway).
// Forces every non-JS client to camel-case manually or reach for a converter.
// Future rename to snake_case is a breaking change for every consumer.
```

**Incorrect (mixed casing — worst of both):**

```json
{
  "session_id": "cs_test_123",
  "paymentIntentId": "pi_X",
  "amount_captured": 2000,
  "refundIssued": true
}
```

```text
// Two conventions in one response — consumers can never predict the casing of a new field.
// Symptom of multiple authors not enforcing the convention; signals a missing review gate.
```

**Correct (snake_case uniformly):**

```json
{
  "session_id": "cs_test_123",
  "payment_intent_id": "pi_X",
  "amount_captured": 2000,
  "refund_issued": true,
  "canceled_by": "customer"
}
```

```text
// Single convention everywhere. No mental switching for consumers.
// SDKs can mechanically map to language conventions:
//   TS: { sessionId: response.session_id, paymentIntentId: response.payment_intent_id }
// One mapping layer in the SDK; rest of the wire stays clean.
```

**The convention extends to:**

| Surface | Example |
|---------|---------|
| JSON response fields | `"amount_captured": 2000` |
| Form-encoded request fields | `metadata[order_id]=6735` |
| Query string params | `?starting_after=cus_X&created[gte]=1672531200` |
| Enum values | `"status": "requires_action"` |
| Event types | `"type": "payment_intent.succeeded"` |
| Error codes | `"code": "card_declined"` |
| Action endpoint verbs | `POST /v1/invoices/{id}/finalize` |

**Multi-word values stay snake_case** (`requires_payment_method`, not `requiresPaymentMethod` or `requires-payment-method`).

**Acronyms are lowercase** — `id` not `ID`, `url` not `URL`, `api_version` not `API_version`. The lowercase rule beats acronym capitalisation.

**SDKs translate, the wire doesn't:**

```typescript
// TypeScript SDK exposes camelCase for ergonomics:
const charge = await stripe.charges.retrieve('ch_X');
charge.amountCaptured;  // 2000

// But the underlying request/response is snake_case:
// GET /v1/charges/ch_X → { "amount_captured": 2000, ... }
```

Reference: [Stripe API reference](https://docs.stripe.com/api)
