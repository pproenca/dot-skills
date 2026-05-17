---
title: One Object Per Request — No Bulk Endpoints
impact: HIGH
impactDescription: prevents partial-success ambiguity and broken idempotency scope
tags: url, bulk, idempotency, error-semantics
---

## One Object Per Request — No Bulk Endpoints

Each request creates, updates, or deletes a single object. Stripe explicitly states "only one object per request is supported," and the rule is deliberate: bulk endpoints make partial success a primary concern (did 7 of 10 records save? which 3 failed? what does the response shape look like when half succeed?), break idempotency scoping (one `Idempotency-Key` for ten heterogeneous operations?), and complicate rate-limit accounting.

When integrators need throughput, the answer is parallel single-object requests with HTTP/2 multiplexing or async batch jobs (`POST /v1/file_uploads` → poll for completion). The cost of a per-object round trip is small; the cost of getting bulk-error semantics wrong is large and permanent.

**Incorrect (bulk endpoint with partial success):**

```text
POST /v1/charges/bulk
Content-Type: application/json

[
  { "amount": 1000, "currency": "usd", "source": "tok_a" },
  { "amount": 2000, "currency": "usd", "source": "tok_b" },
  { "amount": 3000, "currency": "usd", "source": "tok_c" }
]

# Response: which status code if 2 succeed and 1 fails?
# How does the client retry just the failed one?
# What's the Idempotency-Key scope — the whole batch or each charge?
```

**Incorrect (bulk with mixed-success envelope):**

```json
{
  "results": [
    { "status": "ok", "charge": { "id": "ch_1", ... } },
    { "status": "ok", "charge": { "id": "ch_2", ... } },
    { "status": "error", "error": { "type": "card_error", ... } }
  ]
}
```

```text
// Client must parse a discriminated array of successes and failures.
// Idempotent retry of just the failed item is impossible without per-item keys.
// The "envelope of envelopes" shape doesn't match any other endpoint.
```

**Correct (one object per request, parallel client-side):**

```text
POST /v1/charges
Idempotency-Key: 4ab9c8a1-7e3d-4c8f-9b21-7d1f3c5e8a91

amount=1000&currency=usd&source=tok_a
```

```javascript
// Client parallelises with native concurrency:
const charges = await Promise.all(
  cartItems.map(item =>
    stripe.charges.create(
      { amount: item.amount, currency: 'usd', source: item.token },
      { idempotencyKey: item.idempotencyKey }
    )
  )
);
// Each charge has its own idempotency scope, error response, retry semantics.
// Failures surface as rejected promises — standard concurrency handling.
```

**When bulk is legitimately needed** (importing thousands of records nightly): provide an async batch endpoint that returns a job ID and is polled for completion (Stripe's File Uploads, Reporting). The job model puts batch semantics where they belong — in a long-running background workflow, not in the synchronous resource API.

Reference: [Stripe API — request semantics](https://docs.stripe.com/api/charges/create)
