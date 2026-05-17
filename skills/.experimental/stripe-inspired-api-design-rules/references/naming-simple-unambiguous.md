---
title: Names — Simple, Unambiguous, No Leading Digits, No Jargon
impact: MEDIUM
impactDescription: prevents naming debt that requires version bumps to fix
tags: naming, identifiers, clarity, jargon
---

## Names — Simple, Unambiguous, No Leading Digits, No Jargon

Field and resource names are plain language, unambiguous, and lexically valid in every common programming language. Concretely: don't start with a digit (breaks identifier syntax in most languages); don't include industry jargon when a plain word exists; don't reuse the same name for two different things in the same response; and don't embed vendor or implementation details in identifiers that should outlive them.

These look like trivia individually, but each one is a name that, once shipped, can only be changed via a breaking-version cycle. Catching them at PR review is free; catching them in v2 is expensive.

**Incorrect (leading digit, jargon, vendor leak):**

```json
{
  "3ds_required": true,                    // identifier starts with digit
  "kyc_eddc_status": "approved",            // industry jargon (EDD-C)
  "stripeCheckoutSessionId": "cs_test_X"   // vendor name in field
}
```

```text
// `3ds_required` breaks JS/Python/Java identifier syntax — accessors need quotes/brackets.
// `kyc_eddc_status` — only KYC specialists know "EDD-C" (Enhanced Due Diligence Compliance).
// `stripeCheckoutSessionId` couples the API surface to a specific payment provider.
// Renaming any of these later requires a dated-version migration.
```

**Incorrect (same name for two different things):**

```json
{
  "amount": 2000,
  "items": [
    { "amount": 1500 },     // is this the item subtotal? quantity? unit price?
    { "amount": 500 }
  ]
}
```

```text
// `amount` at top level means "total"; `amount` per item means... what?
// Consumers must read docs to disambiguate. Some will guess wrong.
```

**Incorrect (overly clever or playful):**

```json
{
  "moolah": 2000,           // slang
  "boop_at": 1672531200,    // cute, opaque
  "yeet_threshold": 500     // ¯\_(ツ)_/¯
}
```

```text
// Cute names rot. The team that thought "yeet" was funny in 2024 won't in 2028.
// Non-English speakers (most of the internet) have no chance.
// Imagine these in a production incident at 3am.
```

**Correct (simple, plain language, no jargon, no leading digit, no vendor leak):**

```json
{
  "amount": 2000,                    // total
  "items": [
    { "unit_price": 1500 },          // unambiguous: per-item price
    { "unit_price": 500 }
  ],
  "three_d_secure_required": true,   // spelled out, alphabetic-first
  "verification_status": "approved", // plain language, not "kyc_eddc_status"
  "checkout_session_id": "cs_test_X" // no vendor name — prefix is on the value
}
```

```text
// Every field name reads as English. No jargon decoder ring needed.
// Identifiers are valid in every language without quoting.
// Vendor-neutral — the cs_ prefix on the value signals provenance to those who care.
```

**Naming rules to apply at PR review:**

| Rule | Example bad | Example good |
|------|-------------|--------------|
| Don't start with a digit | `3ds_required` | `three_d_secure_required` |
| Don't include vendor names | `stripe_session_id` | `checkout_session_id` |
| Don't use abbreviations specific to one industry | `kyc_eddc_status` | `verification_status` |
| Don't reuse a name for different concepts in the same response | `amount` (total) + `amount` (per item) | `amount` + `unit_price` |
| Don't use slang, jokes, or culturally-specific terms | `moolah`, `yeet_threshold` | `amount`, `refund_limit` |
| Don't use language-reserved words | `class`, `type` (sometimes), `default` | `kind`, `payment_type`, `default_method` |
| Prefer the resource name as a context (don't repeat it) | `customer.customer_email` | `customer.email` |
| Don't pluralise singular concepts | `informations`, `metadatas` | `information`, `metadata` |
| Don't suffix booleans with `_flag` | `active_flag` | `active` |

**A name that needs a comment to explain it is the wrong name.** Rename it before merge.

Reference: [Stripe API field names](https://docs.stripe.com/api)
