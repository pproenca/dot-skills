---
title: Allow Dot-Notation for Nested Expansion (Max Depth 4)
impact: MEDIUM-HIGH
impactDescription: prevents N+1 round trips for chained relationship traversal
tags: format, expand, nested, depth-limit
---

## Allow Dot-Notation for Nested Expansion (Max Depth 4)

Expansion supports chained traversal via dot notation: `expand[]=payment_intent.customer` inflates the charge's `payment_intent`, and within that, the `customer` field as well. The chain can go up to four levels deep (`expand[]=invoice.subscription.customer.default_source`). The depth limit exists because each level multiplies join cost; beyond four, the right tool is usually a dedicated denormalised endpoint or a search query.

This is what makes `expand` competitive with GraphQL for read-heavy traversal workloads. A complex page view ("show the charge, the customer who owns it, the subscription tied to the customer, the customer's default payment method") becomes a single round trip with one expand string instead of four sequential fetches.

**Incorrect (only single-level expansion → still N+1 for chains):**

```text
GET /v1/charges/ch_X?expand[]=payment_intent
# Returns payment_intent inline, but customer inside is still an ID

GET /v1/customers/cus_X
# Second round trip to inflate the customer
```

**Correct (dot notation traverses relationships):**

```text
GET /v1/charges/ch_X?expand[]=payment_intent&expand[]=payment_intent.customer
```

```json
{
  "id": "ch_X",
  "object": "charge",
  "payment_intent": {
    "id": "pi_X",
    "object": "payment_intent",
    "customer": {
      "id": "cus_X",
      "object": "customer",
      "email": "jenny@example.com",
      ...
    }
  }
}
```

**Multi-level chain (up to 4 levels):**

```text
GET /v1/invoices/in_X?expand[]=subscription.customer.default_source
```

```text
// 1. Inflate invoice.subscription
// 2. Within subscription, inflate subscription.customer
// 3. Within customer, inflate customer.default_source
// Single round trip; would have been 3 sequential without expansion.
```

**For list responses, prefix with `data.`:**

```text
GET /v1/charges?expand[]=data.customer&expand[]=data.payment_intent.invoice&limit=20
```

**Enforce the depth limit server-side and return an explicit error if exceeded:**

```json
HTTP/1.1 400 Bad Request

{
  "error": {
    "type": "invalid_request_error",
    "code": "expansion_depth_exceeded",
    "message": "Expansion paths cannot exceed 4 levels deep. Got 5 levels in 'invoice.subscription.customer.default_source.usage'.",
    "param": "expand[]"
  }
}
```

**When NOT to use deep expansion:**
- When the same expansion is needed on many list items (consider denormalising on the server, returning the related fields directly)
- When the expanded data is huge (large arrays inside the expansion) — pay the N+1 cost rather than balloon the payload
- When the consumer only needs one field of the related object — design a specific endpoint or use the search API

**Document expansion paths in `x-expansionResources` (OpenAPI vendor extension)** so SDK codegen can produce type-safe nested expansion APIs.

Reference: [Stripe expanding objects](https://docs.stripe.com/api/expanding_objects)
