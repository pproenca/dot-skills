---
title: Discriminate Polymorphic Types with a `type` Field and Sibling Objects
impact: HIGH
impactDescription: prevents untagged unions that require runtime type-sniffing
tags: naming, polymorphism, discriminator, type
---

## Discriminate Polymorphic Types with a `type` Field and Sibling Objects

When a field can hold one of several variants — a PaymentMethod can be a card, a SEPA debit, a US bank account, etc. — use a `type` discriminator field with type-specific data under sibling objects named identically to the type value. Only the sibling matching the current `type` is populated; the others are `null` or absent. This pattern produces a single, stable schema that every variant fits, and lets SDK code generators emit one polymorphic deserialiser instead of N runtime sniffers.

The alternative — untagged unions (`payment_method: card | sepa | bank`) or per-variant endpoints — forces consumers to write `if (payment_method.last4) ... else if (payment_method.iban) ...`. That kind of structural type-sniffing is fragile (a new variant with a `last4` field could be mistaken for a card) and impossible to validate statically.

**Incorrect (untagged union — type inferred from field presence):**

```json
{
  "id": "pm_X",
  "object": "payment_method",
  "last4": "4242",
  "exp_month": 12,
  "exp_year": 2030,
  "brand": "visa"
}
```

```text
// What kind of payment method is this? Looks like a card — `last4`, `exp_month`, `brand` are card-shaped fields.
// A future US bank account variant could have its own `last4` (last 4 of account number).
// Type sniffing breaks: `if (pm.last4 && pm.exp_month) treatAsCard(pm)` — until SEPA also has last4.
```

**Incorrect (per-variant endpoint with no shared schema):**

```text
GET /v1/cards/card_X        → { "id": ..., "last4": ... }
GET /v1/sepa_debits/sepa_X  → { "id": ..., "iban": ... }
GET /v1/us_bank_accounts/ba_X → { "id": ..., "routing": ... }
```

```text
// No unified resource — can't list "all payment methods on customer X".
// SDKs need per-variant types; no shared interface.
// Adding a new variant means a new endpoint, new resource, new types.
```

**Correct (`type` discriminator + sibling objects):**

```json
{
  "id": "pm_X",
  "object": "payment_method",
  "type": "card",
  "card": {
    "brand": "visa",
    "last4": "4242",
    "exp_month": 12,
    "exp_year": 2030,
    "fingerprint": "..."
  },
  "sepa_debit": null,
  "us_bank_account": null,
  "billing_details": { "name": "Jenny Rosen", "email": "..." },
  "metadata": {}
}
```

```json
// Same schema, different variant:
{
  "id": "pm_Y",
  "object": "payment_method",
  "type": "us_bank_account",
  "card": null,
  "sepa_debit": null,
  "us_bank_account": {
    "account_type": "checking",
    "bank_name": "Stripe Test Bank",
    "last4": "6789",
    "routing_number": "110000000"
  },
  "billing_details": { "name": "Jenny Rosen", "email": "..." },
  "metadata": {}
}
```

```text
// Single schema fits every variant. Generic list endpoint works:
//   GET /v1/customers/cus_X/payment_methods?type=card  (also filter by type)
// SDK polymorphic deserialiser:
//   switch (pm.type) { case 'card': return parseCard(pm.card); case 'us_bank_account': ... }
// Adding a new variant: add a new `type` value + a new sibling object. Backwards-compatible.
```

**Shared fields stay at the top level** — `id`, `object`, `type`, `billing_details`, `metadata`, `created` apply to every variant regardless of `type`. Variant-specific data lives in the named sibling.

**Sibling object names match the `type` value exactly:** `type: "card"` → field `card`; `type: "us_bank_account"` → field `us_bank_account`. The mechanical correspondence lets clients write `pm[pm.type]` to extract the variant-specific data in any dynamic language.

**Empty siblings are `null`, not absent.** Stripe explicitly returns `card: null` on a SEPA-typed payment method — this keeps the response shape deterministic and lets schema validators check that every sibling field exists. The explicit `null` is part of the polymorphic schema contract; the absence-vs-`null` choice for non-polymorphic optional fields is separate.

**The discriminator is a string enum,** not a boolean (`is_card: true`) or a numeric code (`type: 1`). Strings are self-describing in logs and tooling; integers are opaque without a translation table.

**Adding a new variant is backwards-compatible** if clients tolerate unknown `type` values (see [`ver-tolerate-unknown`](ver-tolerate-unknown.md)). Old SDKs receive `type: "new_variant"` and fall through to a generic handler without crashing.

Reference: [Stripe PaymentMethod object](https://docs.stripe.com/api/payment_methods/object)
