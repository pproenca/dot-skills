---
title: Use a Small Fixed `type` Enum, Don't Proliferate Types
impact: HIGH
impactDescription: prevents error-type explosion that defeats generic handling
tags: error, enum, classification, types
---

## Use a Small Fixed `type` Enum, Don't Proliferate Types

Stripe ships exactly four error types: `api_error`, `card_error`, `idempotency_error`, `invalid_request_error`. Every error in the API falls into one of these four buckets — and the bucket determines how the client should react (retry, surface to user, alert engineering, fix the request). New error categories don't get new types; they get new `code` values within an existing type.

The discipline matters because the `type` field is the **classification axis** clients use to write generic handlers. With four types, every integrator can write a four-branch switch and cover the entire error surface. With twenty types, integrators end up grouping them anyway, and they group them inconsistently. The constraint forces the API team to think carefully about which client reaction each error class implies.

**The four types and what they tell the client to do:**

| `type` | Meaning | Client reaction |
|--------|---------|-----------------|
| `api_error` | Server-side problem (5xx) | Retry with backoff; alert engineering if persistent |
| `card_error` | Payment method rejected by the card network | Surface to the end user; let them try another card |
| `idempotency_error` | Idempotency key reused with different params | Fix the bug — never retry |
| `invalid_request_error` | Malformed request (4xx, not card-related) | Fix the request — never retry |

**Incorrect (type-per-failure-mode proliferation):**

```json
{ "error": { "type": "card_declined_generic" } }
{ "error": { "type": "card_declined_insufficient_funds" } }
{ "error": { "type": "card_expired" } }
{ "error": { "type": "card_cvc_check_failed" } }
{ "error": { "type": "rate_limit_exceeded" } }
{ "error": { "type": "request_field_missing" } }
{ "error": { "type": "request_field_invalid" } }
{ "error": { "type": "internal_server_error" } }
{ "error": { "type": "database_timeout" } }
```

```text
// Generic error handling becomes infeasible — must enumerate every type.
// New failure modes need SDK updates to recognise their type.
// Grouping logic ("is this a user-facing payment failure?") differs across integrators.
```

**Correct (four types, infinite codes within them):**

```json
// Card declines — all type: card_error, differ by code/decline_code
{ "error": { "type": "card_error", "code": "card_declined", "decline_code": "generic_decline" } }
{ "error": { "type": "card_error", "code": "card_declined", "decline_code": "insufficient_funds" } }
{ "error": { "type": "card_error", "code": "expired_card" } }
{ "error": { "type": "card_error", "code": "incorrect_cvc" } }

// Validation problems — all type: invalid_request_error, differ by code
{ "error": { "type": "invalid_request_error", "code": "parameter_missing", "param": "amount" } }
{ "error": { "type": "invalid_request_error", "code": "parameter_invalid_integer", "param": "amount" } }

// Server-side — type: api_error
{ "error": { "type": "api_error", "message": "An unexpected error occurred." } }

// Idempotency violation — separate type because the action is unique (fix bug, never retry)
{ "error": { "type": "idempotency_error", "code": "idempotency_key_in_use" } }
```

```text
// Four-branch client switch covers every error in the API:
//   card_error           → show to user
//   invalid_request_error → log and surface to developer
//   idempotency_error    → never retry, fix the bug
//   api_error            → retry with backoff
```

**Why `idempotency_error` is its own type** even though it's structurally a request error: the action is unique. Retry is dangerous (the same key with different params is a bug); surfacing to users is wrong (they didn't do anything). Putting it in its own type forces integrators to handle it correctly.

**Adding a new type is a breaking change** because every client's exhaustive switch needs a new branch. The four-type ceiling is intentional — additions require a major review.

Reference: [Stripe errors](https://docs.stripe.com/api/errors)
