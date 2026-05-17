---
title: Expand Related Objects with `expand[]` in One Round Trip
impact: MEDIUM-HIGH
impactDescription: prevents N+1 round trips when consumers need related resources
tags: format, expand, related-objects, n-plus-one
---

## Expand Related Objects with `expand[]` in One Round Trip

By default, related resources are returned as ID strings: a charge's `customer` field is `"cus_NffrFeUfNV2Hib"`, not the full customer object. Integrators that need the related object can request inflation with `expand[]=<field>` on the same request: `GET /v1/charges/ch_X?expand[]=customer`. The server returns the customer object inline, replacing the ID. This is Stripe's answer to the GraphQL "I want this object plus those related objects" problem without introducing a query language.

Without `expand`, the alternative is N+1 round trips — fetch the charge, then fetch the customer, then for each invoice fetch its line items. For a list of 100 charges with three expansions, that's 301 sequential requests vs. one. `expand` collapses all of them into a single response while still letting the caller opt out of payload bloat when they don't need the related objects.

**Incorrect (no expansion mechanism → N+1):**

```javascript
const charge = await stripe.charges.retrieve('ch_X');
const customer = await stripe.customers.retrieve(charge.customer);
const paymentIntent = await stripe.paymentIntents.retrieve(charge.payment_intent);
const paymentMethod = await stripe.paymentMethods.retrieve(paymentIntent.payment_method);
// 4 sequential round trips for one logical view
```

**Incorrect (eager hydration of all relationships):**

```json
// API always returns full customer object — bloats every response
GET /v1/charges/ch_X
{
  "id": "ch_X",
  "customer": {
    "id": "cus_X",
    "email": "...",
    "subscriptions": { ... },  // and these...
    "invoices": { ... }        // and these...
  }
}
```

```text
// Payloads grow unboundedly. Consumers that just need the charge ID pay for everything.
// Cyclic references (customer → charges → customer) require ad-hoc cycle breaking.
```

**Correct (`expand[]` opt-in inflation):**

```text
# Default — related fields are ID strings
GET /v1/charges/ch_X

# Response
{
  "id": "ch_X",
  "object": "charge",
  "customer": "cus_NffrFeUfNV2Hib",
  "payment_intent": "pi_3MqZ..."
}

# With expansion — related fields are full objects
GET /v1/charges/ch_X?expand[]=customer&expand[]=payment_intent

# Response
{
  "id": "ch_X",
  "object": "charge",
  "customer": {
    "id": "cus_NffrFeUfNV2Hib",
    "object": "customer",
    "email": "jenny@example.com",
    ...
  },
  "payment_intent": {
    "id": "pi_3MqZ...",
    "object": "payment_intent",
    ...
  }
}
```

**`expand` works on every shape of endpoint — list, retrieve, create, update.** For list responses, expansions are prefixed with `data.`:

```text
GET /v1/charges?expand[]=data.customer&limit=10
```

**Document which fields are expandable** in the OpenAPI spec using the `x-expandableFields` vendor extension so SDK code generators can produce type-safe expansion helpers:

```yaml
Charge:
  properties:
    customer:
      type: string  # default
    # ...
  x-expandableFields:
    - customer
    - payment_intent
    - invoice
    - balance_transaction
```

**Also use `expand` to surface fields that are hidden by default** (sensitive data like card numbers on Issuing Cards — opt-in via `expand[]=number`).

For nested expansion (`payment_intent.customer`), see [`format-dot-notation-expansion`](format-dot-notation-expansion.md).

Reference: [Stripe expanding objects](https://docs.stripe.com/api/expanding_objects)
