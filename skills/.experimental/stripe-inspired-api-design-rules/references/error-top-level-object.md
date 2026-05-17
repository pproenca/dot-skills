---
title: Always Wrap Failures in a Top-Level `error` Object
impact: HIGH
impactDescription: prevents bespoke error parsing per endpoint
tags: error, envelope, contract
---

## Always Wrap Failures in a Top-Level `error` Object

Every error response has the same envelope: a single top-level `error` object containing the failure details. Successful responses are the resource itself; failures are `{ "error": { ... } }`. The shape is consistent across every endpoint and every status code, so clients write error handling once and reuse it everywhere.

Without a uniform envelope, integrators end up with per-endpoint error parsing (`if response.status === 400 && response.body.violations`, `if response.body.error_code`, `if response.body.errors[0].message`), and every new error format requires an SDK update. With the envelope, a single `if (response.error)` check works for the entire API.

**Incorrect (ad-hoc error shapes per endpoint):**

```json
// One endpoint:
{ "ok": false, "code": "SLOT_TAKEN" }

// Another endpoint:
{ "errors": [{ "field": "email", "msg": "invalid" }] }

// Another endpoint (success-looking shape with hidden failure):
{ "result": null, "warning": "card declined" }
```

```text
// Every endpoint forces a different parser.
// Integrators write switch statements over status code AND body shape.
// A new endpoint's error format breaks generic logging and monitoring.
```

**Incorrect (errors in a `data` field — looks like success):**

```json
HTTP/1.1 400 Bad Request

{
  "data": {
    "code": "card_declined",
    "message": "Your card was declined."
  }
}
```

```text
// A naive `if (response.data)` check treats the failure as success.
// No structural cue that this is an error envelope.
```

**Correct (top-level `error` object, consistent across the API):**

```json
HTTP/1.1 402 Payment Required

{
  "error": {
    "type": "card_error",
    "code": "card_declined",
    "decline_code": "generic_decline",
    "message": "Your card was declined.",
    "param": "card[number]",
    "doc_url": "https://stripe.com/docs/error-codes/card-declined",
    "charge": "ch_3MqZ...",
    "request_log_url": "https://dashboard.stripe.com/test/logs/req_abc"
  }
}
```

```text
// Single envelope shape across every endpoint and every status.
// Client check: if (response.error) handleError(response.error)
// Generic logger can extract type, code, message uniformly.
```

**Validation errors use the same envelope** — there is no separate `errors[]` array for multi-field validation. Stripe returns a single `invalid_request_error` with `param` naming the offending field; the client retries with a fix. This forces APIs to fail fast on the first invalid field rather than collecting validation across a whole submission. See [`error-message-mandatory-code-optional`](error-message-mandatory-code-optional.md).

**Required and optional fields inside `error`:**

| Field | Required | Purpose |
|-------|----------|---------|
| `type` | required | one of 4 enum values (see [`error-four-type-enum`](error-four-type-enum.md)) |
| `message` | required | human-readable explanation |
| `code` | optional | machine-readable identifier (only when programmatically handleable) |
| `param` | optional | name of the offending request field |
| `doc_url` | recommended | link to error documentation (see [`error-doc-url-on-every-error`](error-doc-url-on-every-error.md)) |
| `request_log_url` | recommended | link to the request in the dashboard for support workflows |

Reference: [Stripe errors](https://docs.stripe.com/api/errors)
