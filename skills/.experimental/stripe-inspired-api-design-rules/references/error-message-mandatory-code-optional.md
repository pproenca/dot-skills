---
title: "Require `message`; Make `code` Optional and Only for Programmatic Handling"
impact: HIGH
impactDescription: prevents hardcoded code-to-text mappings in every client
tags: error, message, code, classification
---

## Require `message`; Make `code` Optional and Only for Programmatic Handling

Every error response includes a human-readable `message` — it is never absent. The `code` field is optional and only present when a developer needs to handle the error programmatically (`card_declined`, `expired_card`, `idempotency_key_in_use`). Integration-misuse errors (sent a malformed request, used the wrong endpoint) don't get codes because there's no useful programmatic reaction — the right fix is to read the message and fix the integration.

Omitting `message` forces every client to maintain a hardcoded `code → text` map. Omitting `code` for handleable failures forces every client to do error matching via brittle string comparison on `message`. The split — `message` always, `code` selectively — gives both audiences what they need without redundancy.

**Incorrect (code-only error, no message):**

```json
{
  "error": {
    "code": "SLOT_TAKEN"
  }
}
```

```text
// Client must hardcode: "SLOT_TAKEN" → "This slot is no longer available. Please choose another."
// Every integrator writes the same translation table.
// Updating the user-facing text requires every client SDK to update.
// Codes also use SCREAMING_SNAKE_CASE — see error-lowercase-snake-case-codes.
```

**Incorrect (codes for everything, including non-handleable errors):**

```json
{
  "error": {
    "type": "invalid_request_error",
    "code": "amount_must_be_positive_integer",
    "message": "amount must be a positive integer"
  }
}
```

```text
// "amount_must_be_positive_integer" is not programmatically handleable — what would the client do
// differently than reading the message? The code is dead weight.
// The integrator's job is to read the message and fix their request.
```

**Correct (message always, code only when handleable):**

```json
// Card decline — code is essential because clients route differently per decline type
{
  "error": {
    "type": "card_error",
    "code": "card_declined",
    "decline_code": "insufficient_funds",
    "message": "Your card has insufficient funds.",
    "param": "card[number]",
    "doc_url": "https://stripe.com/docs/error-codes/card-declined"
  }
}
```

```json
// Integration misuse — no code; the message is the actionable signal
{
  "error": {
    "type": "invalid_request_error",
    "message": "Received unknown parameter: amout. Did you mean: amount?",
    "param": "amout",
    "doc_url": "https://stripe.com/docs/api/charges/create"
  }
}
```

```text
// Cards: integrator handles `code: "card_declined"` programmatically (retry? prompt? alternate method?)
// Integration error: no code — read the message, fix the typo, redeploy.
```

**Writing a good `message`:**
- Specific about the problem (`"amount must be at least 50"` not `"invalid amount"`)
- Actionable (`"Use a different card or contact your bank"` not `"Card declined"`)
- Includes the offending value when safe to do so (`"Received unknown parameter: amout. Did you mean: amount?"`)
- Free of placeholder text (`"An error occurred"` is a bug)

**When you do include a `code`**, it must follow the lowercase snake_case convention — see [`error-lowercase-snake-case-codes`](error-lowercase-snake-case-codes.md). Once published, codes are part of the API contract; renaming is a breaking change.

**For card declines, also include `decline_code`** (the issuer's reason) and `advice_code` (what to do next). See [`error-decline-code-extras`](error-decline-code-extras.md).

Reference: [Stripe error codes](https://docs.stripe.com/error-codes)
