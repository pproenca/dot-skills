---
title: Provide a `metadata` Pass-Through with Strict Limits
impact: MEDIUM-HIGH
impactDescription: prevents per-customer schema requests for arbitrary tagging needs
tags: naming, metadata, extensibility, customer-data
---

## Provide a `metadata` Pass-Through with Strict Limits

Every mutable resource has a `metadata` field — a flat key-value map for customer-defined data the API itself doesn't read. Stripe specifies hard limits: 50 keys, keys up to 40 characters, values up to 500 characters, all stored as strings. The platform never interprets metadata for processing or authorisation; it's pure passthrough.

This pattern absorbs ~90% of "can you add a field for X?" requests without expanding the official schema. Integrators tag charges with their internal order IDs, link customers to their CRM, attach context for support — all without needing the API team to add a field. The strict limits prevent metadata from becoming a poor-man's database (large blobs, many keys, attempted schema enforcement).

**Incorrect (no metadata field — every tagging need becomes a feature request):**

```json
{
  "id": "ch_X",
  "object": "charge",
  "amount": 2000
}
```

```text
// Integrator wants to link this charge to their internal order #6735.
// Options: (a) store the link in their database, do a join later (slow, fragile)
//         (b) abuse the `description` field (no structure)
//         (c) file a feature request to add `customer_order_id` — API team adds fields for everyone's special case.
```

**Incorrect (metadata with no limits — becomes a database):**

```json
{
  "metadata": {
    "order_id": "6735",
    "customer_history": "[ 10000-row JSON blob of order history ]",
    "fraud_score_model_v3": "[ 200KB of ML feature vectors ]",
    "...": "...",
    "key_47291": "..."
  }
}
```

```text
// Storage costs explode. Indexes can't handle arbitrary keys.
// Backups, exports, and migrations become unwieldy.
// Integrators stop using their own database; API team becomes accidental database vendor.
```

**Correct (metadata field with documented hard limits):**

```json
POST /v1/charges
Content-Type: application/x-www-form-urlencoded

amount=2000&currency=usd&source=tok_visa&metadata[order_id]=6735&metadata[customer_internal_id]=CUST-91234
```

```json
// Response:
{
  "id": "ch_X",
  "object": "charge",
  "amount": 2000,
  "metadata": {
    "order_id": "6735",
    "customer_internal_id": "CUST-91234"
  }
}
```

```text
// Integrator links the charge to their order without the API team adding a field.
// Listing charges by metadata works: GET /v1/charges?metadata[order_id]=6735 (via search).
// Webhooks include metadata, letting downstream systems reconstruct context.
```

**The limits — and the why behind them:**

| Limit | Value | Why |
|-------|-------|-----|
| Max keys per object | 50 | Storage planning, JSON parse cost, response size |
| Max key length | 40 chars | Index size, log readability |
| Max value length | 500 chars | Prevents metadata-as-blob; forces use of real storage for large data |
| Value type | string only | Predictable serialisation; no type churn |
| Reserved characters in keys | no `[` or `]` | Bracket notation in form-encoded bodies needs unambiguous keys |

**The platform never interprets metadata.** This is the load-bearing promise — the integrator can put whatever they want in there knowing the API won't accidentally take a code path based on metadata content. Authorisation, routing, validation: none of them read metadata.

**Document the no-secrets rule:**

> Do not store sensitive data (card numbers, bank credentials, SSNs, passwords) in `metadata` or `description`. These fields are visible in logs, the dashboard, and webhook payloads to all team members with access.

**Updating metadata:**
- Set `metadata[key]=value` to add or update a single key
- Set `metadata[key]=` (empty value) to remove a single key
- Set `metadata=` (empty top-level) to clear all metadata at once
- Omit `metadata` from the update entirely → metadata unchanged

**Don't ship a `tags` array, a `properties` map, AND a `metadata` map** — pick one and apply it uniformly. Stripe picked `metadata` (lowercase, singular, kv-shaped). Multiple parallel customer-data fields create confusion about which to use.

**For platform-defined custom fields with stricter schemas** (e.g., Stripe Checkout's `custom_fields` for collecting structured input from the buyer), use a separate, dedicated field. `metadata` is for the integrator's pass-through data; structured custom fields are for end-user input.

Reference: [Stripe metadata](https://docs.stripe.com/api/metadata)
