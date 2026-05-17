---
title: Use American English Spelling (`canceled`, Not `cancelled`)
impact: MEDIUM-HIGH
impactDescription: prevents British/American spelling debt that requires a version bump to fix
tags: naming, american-english, spelling, consistency
---

## Use American English Spelling (`canceled`, Not `cancelled`)

API identifiers use American English consistently — `canceled`, `cancel`, `canceling` (single 'l'); `authorize` (not `authorise`); `color` (not `colour`); `behavior` (not `behaviour`); `license` (not `licence`); `analyze` (not `analyse`). The choice doesn't matter; the **consistency** does. Once an API ships with a British spelling on an enum value or event name, fixing it is a breaking change requiring the dated-version migration machinery.

Stripe picked American English and applies it uniformly. The same logic applies to any API team — pick one variant, document it, and audit every shipped identifier. The cost of catching this before launch is zero; the cost of catching it after is a full version-bump cycle for what is essentially a cosmetic issue.

**Incorrect (British spelling on load-bearing identifiers):**

```json
{
  "status": "cancelled_by_customer",
  "object": "appointment"
}
```

```text
// Event: booking/appointment.cancelled
// Field: cancelledBy (also wrong casing — see naming-snake-case-wire-format)
// Once integrators write switch (event.type) { case 'booking/appointment.cancelled': ... },
// renaming to .canceled requires a version-change module.
```

**Incorrect (mixed British and American across the API):**

```json
{
  "cancelled_at": 1672531200,
  "authorized_at": 1672531100,
  "behavior": "manual",
  "colour": "blue"
}
```

```text
// Two consumers reading the docs guess different spellings for the next field.
// Schema validation in any one language flags one variant as a typo.
```

**Correct (American English uniformly):**

```json
{
  "status": "canceled_by_customer",
  "canceled_at": 1672531200,
  "authorized_at": 1672531100,
  "behavior": "manual",
  "color": "blue"
}
```

```text
// Event: booking/appointment.canceled (single 'l')
// Field: canceled_by, canceled_at, canceled_reason
// Consistent across every endpoint, payload, and event in the API.
```

**The most common offenders to audit:**

| British | American | Where to check |
|---------|----------|----------------|
| `cancelled` / `cancelling` | `canceled` / `canceling` | event types, status enums, timestamps |
| `authorised` / `authorisation` | `authorized` / `authorization` | auth-related fields, headers |
| `colour` | `color` | UI/display config |
| `behaviour` | `behavior` | config/settings fields |
| `licence` (noun) | `license` | metadata, attribution |
| `analysed` / `analyser` | `analyzed` / `analyzer` | reporting/analytics fields |
| `optimise` / `organisation` | `optimize` / `organization` | feature names, business fields |
| `centre` | `center` | layout/UI fields |
| `flavour` | `flavor` | variant names |
| `pyjamas` | `pajamas` | (kidding — but audit) |

**Add a CI lint** that flags British spellings in new schema files. The cost is one regex; the benefit is catching the problem at PR time, not at version-bump time.

**Don't mix variants on the same word** — if you ship `canceled` once, every other use must be `canceled`. Mixed spellings (`canceled_at` and `cancelled_by`) on the same resource are the worst signal of a missing review gate.

**If you prefer British English**, that's also fine — what's not fine is mixing or shipping without an explicit choice. Document the choice in your API design guide and audit at PR time.

**Pair this with [`naming-snake-case-wire-format`](naming-snake-case-wire-format.md)** — both rules govern the orthographic conventions of wire identifiers. A `cancelledBy` field violates both (British spelling *and* camelCase) and is the most common signal of a missing review gate on naming.

Reference: [Stripe API conventions](https://docs.stripe.com/api)
