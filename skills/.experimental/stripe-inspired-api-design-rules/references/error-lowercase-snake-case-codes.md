---
title: Use Lowercase snake_case for Error Codes, Not SCREAMING_SNAKE_CASE
impact: MEDIUM-HIGH
impactDescription: prevents casing inconsistency from becoming a breaking-change debt
tags: error, naming, snake-case, codes
---

## Use Lowercase snake_case for Error Codes, Not SCREAMING_SNAKE_CASE

Error codes are lowercase snake_case: `card_declined`, `incorrect_cvc`, `expired_card`, `idempotency_key_in_use`, `slot_taken`. Not `CARD_DECLINED`, not `CardDeclined`, not `card-declined`. The casing is the same as every other identifier on the wire (field names, enum values, event types — see [`naming-snake-case-wire-format`](naming-snake-case-wire-format.md)) because mixed casing breaks every developer's mental model of "all wire identifiers look like this."

Once codes are published they're part of the API contract — integrators write conditional logic on them (`if (error.code === 'card_declined') promptForNewCard()`). Renaming for casing later is a breaking change that requires the dated-version migration machinery. Get it right at launch.

**Incorrect (SCREAMING_SNAKE_CASE — visually shouts, inconsistent with rest of API):**

```json
{
  "error": {
    "code": "SLOT_TAKEN",
    "message": "This slot is no longer available."
  }
}
```

```text
// Inconsistent with snake_case field names everywhere else.
// Looks like a C-style constant, suggesting it's a value the client should #define.
// Renaming to slot_taken later is a breaking change for every consumer.
```

**Incorrect (camelCase — looks like a JavaScript property, not a wire identifier):**

```json
{
  "error": {
    "code": "cardDeclined"
  }
}
```

**Incorrect (kebab-case — inconsistent with field name casing):**

```json
{
  "error": {
    "code": "card-declined"
  }
}
```

**Correct (lowercase snake_case — matches every other identifier):**

```json
{
  "error": {
    "type": "card_error",
    "code": "card_declined",
    "decline_code": "insufficient_funds",
    "message": "Your card has insufficient funds."
  }
}
```

**The convention extends to every code-valued field in the error:**

| Field | Value pattern |
|-------|---------------|
| `type` | snake_case (`card_error`, `invalid_request_error`) |
| `code` | snake_case (`card_declined`, `parameter_missing`) |
| `decline_code` | snake_case (`insufficient_funds`, `generic_decline`) |
| `advice_code` | snake_case (`try_again_later`, `do_not_try_again`) |

**Don't mix casings even within one error response** — every machine-readable string follows the same rule.

**Adding new code values is non-breaking** (clients must tolerate unknown codes gracefully, falling back to the `type`-level handler). **Renaming or recasing an existing code is breaking** and requires the version-change machinery.

Reference: [Stripe error codes](https://docs.stripe.com/error-codes)
