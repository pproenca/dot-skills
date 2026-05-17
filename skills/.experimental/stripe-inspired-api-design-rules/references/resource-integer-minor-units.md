---
title: Use Integer Minor Units for Money, Never Floats
impact: CRITICAL
impactDescription: prevents floating-point precision errors in monetary calculations
tags: resource, money, integers, precision
---

## Use Integer Minor Units for Money, Never Floats

Monetary amounts on the wire are integers in the smallest currency unit — cents for USD, pence for GBP, yen for JPY (a zero-decimal currency). `amount: 2000` with `currency: "usd"` means $20.00. Floats and decimal strings introduce silent precision errors (`0.1 + 0.2 === 0.30000000000000004`), and "whole pounds" representations (`depositAmountGbp: 40`) cannot represent 20% of £49.99 without rounding.

Integer minor units are exactly representable in every language, comparable with standard equality, and survive every JSON parser and column type without loss. The currency code answers "how many minor units per major unit" — see [`resource-currency-field-not-name`](resource-currency-field-not-name.md) for the colocation requirement.

**Incorrect (float in major units — silent precision loss):**

```json
{
  "amount": 9.99,
  "currency": "usd"
}
```

```text
// $9.99 stored as 9.99 (float) loses precision through any arithmetic.
// $9.99 + $0.01 ≠ $10.00 in IEEE 754.
// Tax calculations and split-payment math accumulate drift.
```

**Incorrect (whole-unit integers — can't represent fractions):**

```json
{
  "deposit_amount_gbp": 40,
  "items_total_gbp": 200
}
```

```text
// 20% deposit on a £49.99 treatment = £9.998 — unrepresentable without rounding.
// Currency baked into the name; multi-currency is a breaking change.
// Field name lies about units; consumers must read docs to know it's pounds not pence.
```

**Correct (integer minor units + colocated currency):**

```json
{
  "amount": 999,
  "currency": "usd"
}
```

```text
// $9.99 exactly. Integer arithmetic. No precision drift.
// 20% of £4999 = 999.8 → round-half-even to 1000 pence (£10.00) — explicit, auditable.
```

**Correct (zero-decimal currency):**

```json
{
  "amount": 100,
  "currency": "jpy"
}
```

```text
// ¥100 — JPY has no minor unit; the value is already in major units.
// The currency code tells consumers how many decimals to shift for display.
```

**When NOT to use integer minor units:** for currencies and contexts where sub-minor-unit precision is required (FX rates, micro-payments) — use the `_decimal` string suffix pattern. See [`resource-decimal-suffix-strings`](resource-decimal-suffix-strings.md).

Reference: [Stripe Charge.amount](https://docs.stripe.com/api/charges/object#charge_object-amount), [Stripe zero-decimal currencies](https://docs.stripe.com/currencies#zero-decimal)
