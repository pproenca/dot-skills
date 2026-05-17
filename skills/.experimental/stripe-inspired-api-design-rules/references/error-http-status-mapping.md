---
title: Map Error Types to HTTP Status Codes Consistently
impact: HIGH
impactDescription: prevents intermediaries from misrouting errors and clients from miscategorising them
tags: error, http-status, infrastructure, retries
---

## Map Error Types to HTTP Status Codes Consistently

Each error `type` maps to a specific HTTP status code, and the mapping never varies. Clients route on status code first (because every HTTP library exposes it cheaply, and intermediaries like load balancers, CDNs, and retry middleware see it before the body), then drill into the body for the `type` and `code`. Inconsistent mapping — returning 200 with an error envelope, or 500 for a card decline — defeats every layer of the request stack.

This is also what lets HTTP infrastructure do the right thing automatically: 4xx responses are not retried, 5xx and 429 are retried with backoff, 401 triggers re-auth. Get the status code wrong and clients either pound a failing endpoint forever (4xx returned as 5xx → retries) or silently lose data (5xx returned as 4xx → no retry).

**The canonical mapping:**

| Status | `type` | When |
|--------|--------|------|
| 200 | — (success) | Resource returned |
| 400 | `invalid_request_error` | Malformed request, missing/invalid params |
| 401 | `invalid_request_error` | Missing/invalid API key |
| 402 | `card_error` | Card declined by issuer or network |
| 403 | `invalid_request_error` | Authenticated but lacks permission (e.g., restricted key) |
| 404 | `invalid_request_error` | Resource doesn't exist |
| 409 | `idempotency_error` | Idempotency key reused with different params |
| 424 | `api_error` | External dependency failed (rare, payment-network-specific) |
| 429 | `api_error` (or rate-limit-specific) | Too many requests — client must back off |
| 500 | `api_error` | Server-side bug — retry safely |
| 502, 503, 504 | `api_error` | Transient infrastructure failure — retry with backoff |

**Incorrect (200 + error envelope — defeats every HTTP layer):**

```json
HTTP/1.1 200 OK

{
  "error": {
    "type": "card_error",
    "code": "card_declined",
    "message": "Your card was declined."
  }
}
```

```text
// CDN caches it as a success.
// Retry middleware doesn't fire.
// `fetch().ok` returns true — naive clients treat it as success.
// Monitoring dashboards show 100% success rate during a card-decline incident.
```

**Incorrect (500 for a card decline — triggers infinite retries):**

```json
HTTP/1.1 500 Internal Server Error

{
  "error": {
    "type": "card_error",
    "code": "card_declined"
  }
}
```

```text
// Client retry library sees 5xx → retries with backoff.
// Card network sees N declines per minute for the same card → flags account.
// User charged for retry storm if the card stops declining mid-loop.
```

**Correct (402 for card decline — exactly what HTTP intended):**

```json
HTTP/1.1 402 Payment Required

{
  "error": {
    "type": "card_error",
    "code": "card_declined",
    "decline_code": "insufficient_funds",
    "message": "Your card has insufficient funds.",
    "doc_url": "https://stripe.com/docs/error-codes/card-declined"
  }
}
```

```text
// 4xx → client retry libraries don't retry automatically (correct).
// `fetch().ok` returns false → client error handler runs.
// CDN sees 4xx → doesn't cache.
// Monitoring distinguishes payment failures (402) from server bugs (5xx).
```

**Correct (429 for rate limiting — clients back off natively):**

```text
HTTP/1.1 429 Too Many Requests
Retry-After: 30

{
  "error": {
    "type": "api_error",
    "message": "Rate limit exceeded. Retry after 30 seconds.",
    "doc_url": "https://stripe.com/docs/rate-limits"
  }
}
```

**Include `Retry-After` on 429 and 503** — clients should honour it for backoff timing rather than guessing.

**Never return 2xx with an error envelope.** "Soft failures" returned as 200 are a common anti-pattern that breaks every HTTP-layer assumption.

Reference: [Stripe errors](https://docs.stripe.com/api/errors), [Stripe rate limits](https://docs.stripe.com/rate-limits)
