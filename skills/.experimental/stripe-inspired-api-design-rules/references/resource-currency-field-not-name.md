---
title: Colocate a `currency` Field; Never Bake Currency into Field Names
impact: CRITICAL
impactDescription: prevents multi-currency support becoming a breaking schema change
tags: resource, money, currency, iso-4217
---

## Colocate a `currency` Field; Never Bake Currency into Field Names

Every amount-like field must be accompanied by a sibling `currency` field (ISO 4217 three-letter code, lowercase). Encoding the currency in the field name — `amount_gbp`, `refund_amount_usd`, `deposit_amount_gbp` — turns multi-currency support into a breaking schema change and ships misleadingly long identifiers that lie about their units (they're often in major units, contradicting the integer-minor-units rule).

A single top-level `currency` field is sufficient when every amount on a resource shares one currency (e.g., a charge has one currency for `amount`, `amount_captured`, `amount_refunded`, `application_fee_amount`). When amounts can differ (a multi-currency invoice line item), each amount gets its own `*_currency` sibling.

**Incorrect (currency baked into field name):**

```json
{
  "deposit_amount_gbp": 40,
  "items_total_gbp": 200,
  "refund_amount_gbp": 0
}
```

```text
// Adding EUR support requires `deposit_amount_eur`, `items_total_eur`, ... — breaking change.
// The `_gbp` suffix prevents you from changing currency on an existing resource.
// Field names are noisier and require reading docs to know the unit is pounds not pence.
```

**Correct (single colocated `currency` for one-currency resources):**

```json
{
  "amount": 4000,
  "amount_captured": 4000,
  "amount_refunded": 0,
  "currency": "gbp"
}
```

```text
// All amounts inherit the resource-level currency.
// Multi-currency support is additive: switch the `currency` value, amounts stay integers.
// Field names are clean; the currency code answers "what unit is this in?"
```

**Correct (per-amount `currency` when amounts can differ):**

```json
{
  "object": "invoice_line_item",
  "amount": 1500,
  "currency": "usd",
  "tax_amount": 195,
  "tax_currency": "usd"
}
```

**Rules for the `currency` field itself:**
- Always lowercase ISO 4217 three-letter code: `"usd"`, `"eur"`, `"gbp"`, `"jpy"`.
- Never `"USD"`, never `"$"`, never `"840"` (numeric code), never a symbol.
- Always alongside the amount, never inferred from request metadata or account defaults at read time.

Reference: [Stripe Charge.currency](https://docs.stripe.com/api/charges/object#charge_object-currency), [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217)
