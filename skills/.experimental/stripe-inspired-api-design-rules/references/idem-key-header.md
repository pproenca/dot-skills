---
title: Accept `Idempotency-Key` Header on All Mutating Requests
impact: HIGH
impactDescription: prevents duplicate charges/transfers under network retries
tags: idem, header, retries, mutations
---

## Accept `Idempotency-Key` Header on All Mutating Requests

Every `POST` (create, update, action endpoint) accepts an `Idempotency-Key` header. The server stores the response keyed by `(account, key)` for a TTL window; subsequent requests with the same key return the cached response instead of re-executing. `GET`, `HEAD`, and `DELETE` are inherently idempotent at the HTTP level and don't need keys.

This is the only safe answer to "what happens when the client retries a charge because the network dropped the response?" Without idempotency keys, the safe options are (a) never retry — losing data on transient failures — or (b) hope the operation is naturally idempotent — which charges and transfers absolutely aren't. With keys, the client retries freely; the server guarantees the side effect happens at most once.

**Incorrect (no idempotency mechanism — retries double-charge):**

```javascript
// Client retries on network timeout
async function charge(amount) {
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      return await fetch('/v1/charges', { method: 'POST', body: ... });
    } catch (e) {
      if (e.code === 'ETIMEDOUT') continue;  // retry
      throw e;
    }
  }
}
```

```text
// Attempt 1: server creates charge ch_a, response times out before reaching client.
// Attempt 2: client retries, server creates charge ch_b. Customer is double-charged.
// No way for client to know the first attempt actually succeeded.
```

**Incorrect (custom request-deduplication scheme):**

```javascript
const requestId = uuid();
await fetch('/v1/charges', {
  method: 'POST',
  body: `request_id=${requestId}&amount=2000&...`
});
```

```text
// `request_id` is a request body field, not a header — middleware can't see it.
// No standard way for SDKs to retry automatically with the same dedup token.
// Server has to parse the body to dedupe; can't reject duplicates at the edge.
```

**Correct (Idempotency-Key header on every POST):**

```text
POST /v1/charges HTTP/1.1
Idempotency-Key: 4ab9c8a1-7e3d-4c8f-9b21-7d1f3c5e8a91
Content-Type: application/x-www-form-urlencoded

amount=2000&currency=usd&source=tok_visa
```

```javascript
// SDK generates a key per logical operation; retries reuse the key
const idempotencyKey = uuid();
async function chargeWithRetry(amount) {
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      return await stripe.charges.create(
        { amount, currency: 'usd', source: 'tok_visa' },
        { idempotencyKey }
      );
    } catch (e) {
      if (e.type === 'api_error' && attempt < 2) continue;
      throw e;
    }
  }
}
// Attempt 1: server creates charge ch_a, response lost.
// Attempt 2: server sees same key, returns cached response for ch_a — no second charge.
```

**Key format:** client-generated; the server doesn't impose a format. UUIDs work; any unique string ≤255 chars is fine.

**SDK behaviour:** every official SDK should generate keys automatically when none is provided, so common retries are safe by default. Document the auto-generation so integrators understand it.

**Response indicates whether this was a replay:**

```text
HTTP/1.1 200 OK
Idempotent-Replayed: true
```

So integrators can distinguish "this is the original response" from "this is a cached replay."

**Scope, TTL, and conflict semantics** are covered in [`idem-scoped-per-account`](idem-scoped-per-account.md), [`idem-24h-ttl`](idem-24h-ttl.md), and [`idem-fail-on-key-reuse`](idem-fail-on-key-reuse.md). For multi-step operations, see [`idem-recovery-points`](idem-recovery-points.md).

Reference: [Stripe idempotent requests](https://docs.stripe.com/api/idempotent_requests), [Brandur — idempotency keys](https://brandur.org/idempotency-keys)
