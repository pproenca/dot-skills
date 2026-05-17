---
title: Prefer Enums over Booleans for New Status/Flag Fields
impact: MEDIUM-HIGH
impactDescription: prevents needing a breaking change when a binary flag gains a third state
tags: naming, enums, booleans, extensibility
---

## Prefer Enums over Booleans for New Status/Flag Fields

For genuinely-binary states (`livemode`, `default_for_currency`), a boolean is correct. For anything that *might* gain a third state in the future — a workflow status, a verification result, a content moderation outcome — ship an enum instead. A boolean `verified: true/false` looks adequate today but cannot express `pending`, `requires_action`, `under_review`, or `rejected` without a breaking change. An enum `verification_status: "verified" | "pending" | "rejected"` extends additively as the workflow grows.

The cost of the enum is one extra string per response and slightly more explicit handling in clients; the benefit is permanent forward-compatibility for any workflow that turns out to be richer than initially expected. This pattern matters more for new properties than legacy ones — when you're naming a new field, ask "could this realistically have a third state?" If yes, make it an enum.

**Incorrect (boolean that traps you):**

```json
{
  "refund_issued": true
}
```

```text
// Adding "refund pending" → breaking change. Options:
//   (a) Add `refund_pending: true` alongside → two booleans where one enum belongs.
//   (b) Add `refund_status: "issued" | "pending" | "denied"` → now both fields exist, integrators confused.
//   (c) Change `refund_issued` to nullable → still breaking for clients that don't tolerate null booleans.
```

**Incorrect (boolean for an inherently multi-state workflow):**

```json
{
  "kyc_passed": false
}
```

```text
// Real-world KYC has at least: not_started, in_progress, passed, failed, requires_additional_info.
// Encoding all of that as one boolean loses every distinction except "is the result a pass".
// Integrators write `if (!user.kyc_passed) blockSignup(user)` — but blocking is wrong for `in_progress`.
```

**Correct (enum from the start — additive extensibility):**

```json
{
  "refund_status": "issued"
}
```

```json
// Later, additively:
{
  "refund_status": "pending"
}

// And later:
{
  "refund_status": "denied"
}
```

```text
// Adding values is backwards-compatible if clients tolerate unknown values (ver-tolerate-unknown).
// No breaking change required to evolve the workflow.
// Clients write switch (refund.status) { ... default: ... } — handles new values gracefully.
```

**Correct (verification example):**

```json
{
  "verification_status": "verified"
}

// Initial enum values: "unverified" | "pending" | "verified"
// Later additive value: "rejected" | "requires_additional_info"
// Even later: "manual_review"
// All additive, all non-breaking.
```

**When a boolean is genuinely correct:**

| Boolean is fine | Why |
|-----------------|-----|
| `livemode` | Will always be exactly two values: test or live |
| `default_for_currency` | One default per currency; binary by definition |
| `automatic_tax` (enabled/disabled) | Discrete on/off feature toggle |
| `captured` (in a card-payment context) | Captured-or-not is binary for the lifetime of the charge |

**When an enum is the better choice:**

| Domain | Boolean (bad) | Enum (good) |
|--------|---------------|-------------|
| Workflow outcome | `verified` | `verification_status` |
| Refund state | `refund_issued` | `refund_status` |
| Subscription state | `is_active` | `status` (with `active`, `trialing`, `past_due`, `canceled`, `unpaid`, `incomplete`) |
| Moderation | `approved` | `moderation_status` |
| Dispute lifecycle | `disputed` | `dispute_status` (when nuance matters) |

**The retrofit cost is asymmetric.** Boolean → enum is breaking. Enum with new values → almost always non-breaking. So when in doubt, ship the enum.

**Enum values follow the same casing as all wire identifiers**: lowercase snake_case. See [`naming-snake-case-wire-format`](naming-snake-case-wire-format.md).

**Document enum extensibility upfront:**

> The `status` field is an extensible enum. The current values are listed below, but new values may be added in future versions. Clients must tolerate unknown values gracefully — fall back to a default handler rather than crashing.

Reference: [Stripe Subscription.status](https://docs.stripe.com/api/subscriptions/object#subscription_object-status)
