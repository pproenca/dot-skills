---
title: Return Lists in a `{object, url, has_more, data}` Envelope
impact: HIGH
impactDescription: prevents inconsistent list shapes across endpoints and enables generic SDK iterators
tags: format, lists, envelope, pagination
---

## Return Lists in a `{object, url, has_more, data}` Envelope

Every list response uses the same envelope: `object: "list"`, `url` (the endpoint that produced it), `has_more` (boolean — see [`format-no-total-counts`](format-no-total-counts.md)), and `data` (the array of resources). No other fields. The shape is fixed across every list endpoint in the API so SDKs can ship a single `auto_paginate()` helper, integrators can write one generic list handler, and the convention compounds with [`resource-object-discriminator`](resource-object-discriminator.md) (every item in `data` self-describes its type).

Single-object responses are **not** wrapped — the resource is the root. The envelope is only for lists. Don't add a `{"data": {...}}` wrapper to single-object endpoints "for consistency" — the cost is making every consumer of every endpoint walk into a `data` key for no benefit.

**Incorrect (bespoke list shape per endpoint):**

```json
{
  "customers": [
    { "id": "cus_1", ... },
    { "id": "cus_2", ... }
  ],
  "page": 1,
  "page_size": 10,
  "total_pages": 47
}
```

```text
// Different field names per resource: customers / charges / invoices array.
// Generic SDK iterator must switch on endpoint.
// Page-based pagination breaks under inserts/deletes (see format-cursor-pagination).
```

**Incorrect (envelope used for single objects too):**

```json
GET /v1/customers/cus_X

{
  "data": {
    "id": "cus_X",
    "email": "jenny@example.com"
  }
}
```

```text
// Pointless wrapper — every consumer unwraps `data` to get to the resource.
// Inconsistent with retrieval shape of other APIs; surprises integrators.
```

**Correct (fixed list envelope; single objects unwrapped):**

```json
GET /v1/customers?limit=2

{
  "object": "list",
  "url": "/v1/customers",
  "has_more": true,
  "data": [
    { "id": "cus_1", "object": "customer", "email": "jenny@example.com", ... },
    { "id": "cus_2", "object": "customer", "email": "lou@example.com", ... }
  ]
}
```

```json
GET /v1/customers/cus_1

{
  "id": "cus_1",
  "object": "customer",
  "email": "jenny@example.com",
  ...
}
```

**The four fields and only the four fields:**

| Field | Type | Value |
|-------|------|-------|
| `object` | string | always `"list"` |
| `url` | string | the request path (helps logging/debugging) |
| `has_more` | boolean | are there more results beyond this page? |
| `data` | array | the resources for this page |

No `total_count`, no `page`, no `next_cursor` field — see [`format-no-total-counts`](format-no-total-counts.md) for why counts are deliberately omitted, and [`format-cursor-pagination`](format-cursor-pagination.md) for how the cursor lives in `starting_after`/`ending_before` query params instead.

Reference: [Stripe pagination](https://docs.stripe.com/api/pagination)
