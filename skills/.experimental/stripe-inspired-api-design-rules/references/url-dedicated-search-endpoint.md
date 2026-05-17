---
title: Use a Dedicated `/search` Endpoint for Complex Queries
impact: MEDIUM-HIGH
impactDescription: prevents eventual-consistency leak into strongly-consistent list endpoints
tags: url, search, list, query
---

## Use a Dedicated `/search` Endpoint for Complex Queries

List endpoints support flat-parameter filtering (`?customer=cus_X&created[gte]=1672531200`) for the simple case — equality and range filters on indexed columns. For full-text matching, boolean combinations (`AND`/`OR`), substring search, and metadata querying, expose a dedicated `/search` sub-resource: `GET /v1/charges/search?query=amount>1000 AND status:succeeded`. The two endpoints have fundamentally different semantics and shouldn't share a URL.

The split matters because list endpoints are strongly-consistent paginated reads from the canonical store, while search runs against an indexed projection with eventual consistency (Stripe documents up to a 1-minute lag). Mixing them on one URL means integrators can't reason about either's guarantees, and adding search after launch becomes a behavioral break for the list endpoint.

**Incorrect (search semantics smuggled into list endpoint):**

```text
GET /v1/charges?q=amount>1000&q=status:succeeded&q_match=any
```

```text
// Overloads list filters with a parallel query-string DSL.
// Integrators can't tell which params are exact-match and which are search-evaluated.
// List endpoint loses its "strongly-consistent, deterministic ordering" guarantee.
```

**Correct (list for filtering, search for queries):**

```text
# List with exact filters and range — strongly consistent
GET /v1/charges?customer=cus_X&created[gte]=1672531200&limit=10

# Search with a query expression — eventual consistency, full text
GET /v1/charges/search?query=customer:"cus_X" AND amount>1000 AND status:"succeeded"
```

```text
// Different contracts at different URLs.
// `/search` documents its eventual-consistency lag explicitly.
// List endpoint stays simple and predictable for the common case.
```

**Search query syntax conventions:**
- `field:value` — exact match (case-insensitive)
- `field~value` — substring (minimum 3 characters)
- `field>value`, `field<value`, `field>=value`, `field<=value` — numeric/timestamp comparisons
- `-field:value` — negation
- `field:null` — presence check
- `metadata["key"]:"value"` — bracket notation for metadata keys
- Boolean combinators: `AND`, `OR` (max 10 clauses per query, can't mix levels)

**Document eventual consistency explicitly:**

> Search results may lag write operations by up to one minute. Avoid read-after-write flows that depend on immediate visibility.

**Search is offered on the resources that need it** (Charges, Customers, Invoices, PaymentIntents, Prices, Products, Subscriptions). Resources without a search index don't get the endpoint — don't ship `/search` for everything just for symmetry.

Reference: [Stripe Search API](https://docs.stripe.com/search)
