---
title: Booleans — Past-Tense Verbs and Plain Adjectives, Not `is_`/`has_` Prefixes
impact: LOW-MEDIUM
impactDescription: prevents inconsistent prefix conventions cluttering field names
tags: naming, booleans, conventions, fields
---

## Booleans — Past-Tense Verbs and Plain Adjectives, Not `is_`/`has_` Prefixes

Stripe's boolean fields use plain adjectives and past-tense verbs without prefixes: `livemode`, `paid`, `captured`, `refunded`, `disputed`, `delinquent`, `cancel_at_period_end`, `default_for_currency`. The convention reads naturally in code (`if (charge.captured)`) and avoids the prefix sprawl that comes from `is_paid`, `has_refund`, `was_captured`, `did_refund` mixed across one API.

This is a minor stylistic rule by itself, but consistency compounds. With a uniform pattern, integrators stop reading docs to remember "is it `is_paid` or `paid` or `has_paid` or `paid_flag`?" and the API surface gets noticeably cleaner.

**Incorrect (mixed prefix conventions — every field is a guess):**

```json
{
  "is_paid": true,
  "has_refund": false,
  "was_captured": true,
  "did_dispute": false,
  "refund_issued": true,
  "cancellation_flag": false
}
```

```text
// Six fields, four different prefix conventions.
// Integrator can never predict whether the next boolean field will be `is_*`, `has_*`, `was_*`, or unprefixed.
// Code reads awkwardly: `if (charge.was_captured && !charge.has_refund && !charge.is_disputed)`
```

**Incorrect (`_flag` suffix — never says anything):**

```json
{
  "active_flag": true,
  "verified_flag": false,
  "premium_flag": true
}
```

```text
// `_flag` is pure noise — adds zero information.
// `active_flag: true` is exactly as informative as `active: true`.
```

**Correct (past-tense verbs and plain adjectives):**

```json
{
  "livemode": false,
  "paid": true,
  "captured": true,
  "refunded": false,
  "disputed": false,
  "delinquent": false,
  "cancel_at_period_end": true,
  "default_for_currency": false
}
```

```text
// Reads naturally: if (charge.captured && !charge.refunded && !charge.disputed)
// Single convention; no guessing about prefixes.
// Field names are shorter; less token cost in logs, payloads, and SQL columns.
```

**The patterns Stripe uses:**

| Pattern | When | Example |
|---------|------|---------|
| Past-tense verb | The state was achieved at some point | `captured`, `refunded`, `paid`, `attempted` |
| Plain adjective | Persistent property of the resource | `livemode`, `delinquent`, `default` |
| Verb phrase | Future-conditional action | `cancel_at_period_end`, `automatic_tax` |
| Negative-prefixed only when natural | Avoid double-negatives | `pause_collection` (object, not boolean) |

**Don't double-negate.** `not_paid: false` is "you must not... not pay" — confusing. Negate the noun instead: `paid: false`.

**Nullable booleans are tri-state.** A `delinquent: null` is meaningfully different from `delinquent: false` ("we don't know yet" vs "we know they aren't"). Document the meaning of `null` explicitly when it's a valid value.

**For new properties that might gain states later, prefer enums** — see [`naming-enums-over-booleans`](naming-enums-over-booleans.md). A `verified: true/false` ships today but cannot express "pending review" without a breaking change.

**Avoid Hungarian notation** (`b_paid`, `bool_captured`) — language types are not part of the field name.

Reference: [Stripe Charge object](https://docs.stripe.com/api/charges/object)
