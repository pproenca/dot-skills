---
title: Use Unix Seconds (Integer) for All Datetimes
impact: CRITICAL
impactDescription: prevents milliseconds/seconds confusion that silently produces wrong times
tags: resource, timestamps, unix, datetime
---

## Use Unix Seconds (Integer) for All Datetimes

Datetimes on the wire are integers counting seconds since the Unix epoch — never milliseconds, never ISO 8601 strings, never locale datetime formats. Field names use plain temporal nouns (`created`, `canceled_at`, `paid_at`, `start_at`) with no unit suffix because the unit is fixed by convention. Sending `startAtMs: 1779876000000` (milliseconds) silently produces wrong times when a consumer passes it to a seconds-based constructor, and the `Ms` suffix is a workaround that acknowledges rather than fixes the deviation.

Consistency wins over ergonomics: when every timestamp in the API is the same shape, integrators learn the rule once. Mixing milliseconds and seconds — or strings and integers — guarantees a category of bugs that surface only across timezone boundaries or DST transitions.

**Incorrect (milliseconds with `Ms` suffix workaround):**

```json
{
  "payment_intent_id": "pi_123",
  "appointment_id": "appt_123",
  "startAtMs": 1779876000000
}
```

```text
// new Date(1779876000000)  → year 2026 (correct if you knew it was ms)
// new Date(1779876000000 * 1000) → year 58353 (silent bug)
// Cross-field comparisons with seconds-based `created` fields are off by a factor of 1000.
```

**Incorrect (ISO 8601 local datetime with no offset):**

```text
POST /reschedule
picked=2026-05-20T10:30
```

```text
// Naive local time. Server must guess the timezone. Breaks across BST/GMT transitions.
```

**Correct (integer Unix seconds):**

```json
{
  "payment_intent_id": "pi_123",
  "appointment_id": "appt_123",
  "start_at": 1779876000
}
```

```text
// Unambiguous. Every consumer interprets it identically.
// Comparable directly with `created`, `canceled_at`, and any other timestamp in the API.
```

**When NOT to use Unix seconds:** for **date-only** values without a time component — use ISO 8601 date strings instead. See [`resource-iso-date-only`](resource-iso-date-only.md).

Reference: [Stripe API — created timestamps](https://docs.stripe.com/api/charges/object)
