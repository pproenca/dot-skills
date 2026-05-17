---
title: Include a Read-Only `object` Discriminator on Every Resource
impact: CRITICAL
impactDescription: enables polymorphic deserialisation and self-describing responses
tags: resource, discriminator, polymorphism, sdk
---

## Include a Read-Only `object` Discriminator on Every Resource

Every API resource must include a top-level, read-only string field that names its type. Stripe uses `"object": "customer"`, `"object": "charge"`, `"object": "list"`. Without a discriminator, SDK deserialisation requires out-of-band knowledge of which endpoint returned which shape, and the first polymorphic response (a list mixing types, a webhook envelope, a `data` field that may hold one of N resources) becomes a one-way breaking change away.

The field name itself isn't load-bearing — `object`, `type`, or `kind` all work — but **once chosen it must be applied uniformly to every resource in the API**. Pick one and never deviate.

**Incorrect (no discriminator — type only inferable from URL):**

```json
GET /v1/customers/cus_NffrFeUfNV2Hib

{
  "id": "cus_NffrFeUfNV2Hib",
  "email": "jenny@example.com",
  "created": 1672531200
}
```

```text
// A generic JSON deserialiser sees: which type?
// Adding a polymorphic list ("data" can be customer or charge) is now a breaking change.
```

**Correct (`object` field uniform across every resource):**

```json
GET /v1/customers/cus_NffrFeUfNV2Hib

{
  "id": "cus_NffrFeUfNV2Hib",
  "object": "customer",
  "email": "jenny@example.com",
  "created": 1672531200
}
```

```text
// Self-describing. SDK switches on `object` to pick the deserialiser.
// List envelopes use the same convention: { "object": "list", "data": [...] }
// Webhook events: { "object": "event", "data": { "object": { "object": "charge", ... } } }
```

**Benefits:**
- SDKs can deserialise polymorphic responses without per-endpoint mapping tables.
- Logs and tooling become self-describing — every snippet identifies its own type.
- Adding polymorphic endpoints later is non-breaking because the discriminator is already there.

Reference: [Stripe API objects](https://docs.stripe.com/api/customers/object)
