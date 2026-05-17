---
title: Include `doc_url` Links and Request IDs on Every Error
impact: MEDIUM-HIGH
impactDescription: prevents support round trips by giving developers direct links to docs and the failed request
tags: error, doc-url, request-id, support
---

## Include `doc_url` Links and Request IDs on Every Error

Every error response includes a `doc_url` field pointing to the documentation page for that error code, and a `request_log_url` pointing to the request in the dashboard. The `doc_url` lets a developer jump straight from a stack trace to "what does `card_declined` mean and what should I do about it"; the `request_log_url` lets them open the exact request in the dashboard to see the full payload, headers, and response without forwarding logs to support.

Both are tiny additions — a single string field each — but they collapse the support funnel dramatically. A developer who hits an unfamiliar error in production usually has two questions: "what is this?" and "what request actually failed?" Putting both answers in the error response itself eliminates the back-and-forth that would otherwise route through documentation search, log queries, and a support ticket.

**Incorrect (error with no documentation pointer or request identifier):**

```json
{
  "error": {
    "type": "card_error",
    "code": "card_declined",
    "message": "Your card was declined."
  }
}
```

```text
// Developer searches docs for "card_declined" — might find the right page, might not.
// Reproducing the failure requires hunting through logs to find the request.
// Support ticket attaches a screenshot; engineer asks for request ID; another round trip.
```

**Correct (doc_url + request_log_url on every error):**

```json
HTTP/1.1 402 Payment Required
Request-Id: req_abc123XYZ

{
  "error": {
    "type": "card_error",
    "code": "card_declined",
    "decline_code": "insufficient_funds",
    "message": "Your card has insufficient funds.",
    "param": "card[number]",
    "doc_url": "https://stripe.com/docs/error-codes/card-declined",
    "request_log_url": "https://dashboard.stripe.com/test/logs/req_abc123XYZ",
    "charge": "ch_3MqZ..."
  }
}
```

```text
// Developer clicks doc_url → docs page for this exact error with handling guidance.
// Developer clicks request_log_url → dashboard view of the full request and response.
// Support ticket includes both URLs; engineer reproduces in seconds.
```

**Also return a `Request-Id` header on every response (success or failure)** — this is what `request_log_url` is built from, and it's what users send to support:

```text
HTTP/1.1 200 OK
Request-Id: req_abc123XYZ
Content-Type: application/json

{ "id": "ch_3MqZ...", "object": "charge", ... }
```

**The `doc_url` is keyed by `code`, not by `type`** — `card_error` is too coarse to document specifically, but `card_declined`, `expired_card`, `incorrect_cvc` each have actionable handling guidance. Generate the URL mechanically:

```text
doc_url = `https://docs.example.com/error-codes/${error.code}`
```

**Include resource-specific identifiers when the error is about a specific resource** — Stripe includes `"charge": "ch_X"` or `"payment_intent": "pi_X"` so the developer can navigate to the affected resource without parsing the request.

**Request IDs are also useful for idempotency debugging:**

```json
{
  "request": {
    "id": "req_abc123",
    "idempotency_key": "4ab9c8a1-7e3d-4c8f-9b21-7d1f3c5e8a91"
  }
}
```

When a retry hits a cached idempotent response, surfacing the original request ID and idempotency key in the response makes "is this a replay?" instantly answerable.

Reference: [Stripe errors](https://docs.stripe.com/api/errors), [Stripe request IDs](https://docs.stripe.com/api/request_ids)
