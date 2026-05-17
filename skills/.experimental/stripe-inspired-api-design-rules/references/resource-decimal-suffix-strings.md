---
title: Use `_decimal` String Suffix for Precise Decimals That Can't Be Integers
impact: HIGH
impactDescription: preserves exact precision for sub-minor-unit values like FX rates and tax rates
tags: resource, money, decimals, precision
---

## Use `_decimal` String Suffix for Precise Decimals That Can't Be Integers

When a value requires precision beyond what an integer minor unit can express — FX rates (`1.0837`), tax rates (`0.08875`), per-unit micro-pricing — represent it as a **string** and suffix the field with `_decimal`. The string serialisation prevents IEEE 754 precision loss in JSON parsers, and the `_decimal` suffix signals to consumers "this field is intentionally a string-encoded decimal; parse it with a decimal library, not a float."

Stripe uses this exact pattern: `unit_amount_decimal` on Prices accepts values like `"0.04"` for fractions of a cent, alongside the integer `unit_amount` for whole-cent prices. The two-field convention lets common cases use the simple integer and exotic cases opt into the precise string.

**Incorrect (float for a precise decimal):**

```json
{
  "unit_amount": 0.04,
  "currency": "usd"
}
```

```text
// JSON parsers may round 0.04 to 0.040000000000000001 or similar.
// Multiplying by usage counts compounds the drift.
// Comparing two "equal" values can return false.
```

**Incorrect (large integer with implicit micro-units):**

```json
{
  "unit_amount_microcents": 40000
}
```

```text
// Unit is buried in the field name and not standard.
// Every consumer has to know the unit multiplier; new units mean new fields.
```

**Correct (string-encoded decimal with `_decimal` suffix):**

```json
{
  "unit_amount_decimal": "0.04",
  "currency": "usd"
}
```

```text
// Exact precision preserved through JSON.
// `_decimal` suffix tells consumers to use BigDecimal / Decimal / decimal.Decimal — not Float.
// Coexists with `unit_amount` (integer cents) for prices that are whole-cent.
```

**Correct (FX rate as decimal string):**

```json
{
  "exchange_rate_decimal": "1.0837"
}
```

**Common use cases:**
- Per-unit prices below one minor unit (`unit_amount_decimal` on metered billing)
- FX and conversion rates
- Tax rates and percentages stored to many decimal places
- Any value where rounding to integer minor units would lose meaningful precision

**Pair with the integer field where the common case is whole units:** offer both `amount` (integer) and `amount_decimal` (string) so consumers default to the simple path.

Reference: [Stripe Price.unit_amount_decimal](https://docs.stripe.com/api/prices/object#price_object-unit_amount_decimal)
