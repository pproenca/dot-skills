---
title: Pluralize Collection URLs; Singularize Object Types
impact: CRITICAL
impactDescription: prevents inconsistent endpoints and hand-written SDK glue per resource
tags: url, naming, rest, sdk
---

## Pluralize Collection URLs; Singularize Object Types

Collection URLs are plural nouns: `/v1/customers`, `/v1/charges`, `/v1/payment_intents`. The `object` discriminator on responses is the singular form: `"object": "customer"`, `"object": "charge"`, `"object": "payment_intent"`. The list endpoint and the create endpoint share the same URL, distinguished only by HTTP verb (`GET` vs `POST`). Item URLs append the ID: `/v1/customers/{id}`.

This convention is mechanical, not aesthetic. SDK code generators can derive every endpoint path from the resource name (`Customer` → `/customers`). Integrators learn the pattern once and predict the URL for every new resource. Mixed plural/singular URLs (`/customer`, `/charges`, `/PaymentIntent`) defeat both.

**Incorrect (singular collection, inconsistent casing):**

```text
POST   /v1/customer           # create — singular collection
GET    /v1/customer/list      # list — invented sub-path
GET    /v1/CustomerById/cus_X # retrieve — inconsistent casing
POST   /v1/customer-update    # update — invented action
```

```text
// Every endpoint needs hand-written SDK glue. No pattern for codegen to follow.
// Two integrators reading the docs guess different URLs for the next resource.
```

**Correct (plural collection, standard CRUD verbs):**

```text
GET    /v1/customers          # list
POST   /v1/customers          # create
GET    /v1/customers/{id}     # retrieve
POST   /v1/customers/{id}     # update (see url-post-for-updates)
DELETE /v1/customers/{id}     # delete
```

```json
// All responses identify themselves with the singular form:
{ "object": "customer", "id": "cus_NffrFeUfNV2Hib", ... }

// List envelopes self-describe:
{ "object": "list", "data": [ { "object": "customer", ... } ], "has_more": false }
```

**The pluralization is structural — apply it to multi-word resources too:**
- `/v1/payment_intents` (not `/v1/payment_intent`)
- `/v1/setup_intents` (not `/v1/setup_intent`)
- `/v1/payment_methods` (not `/v1/payment_method`)

Reference: [Stripe API root](https://docs.stripe.com/api)
