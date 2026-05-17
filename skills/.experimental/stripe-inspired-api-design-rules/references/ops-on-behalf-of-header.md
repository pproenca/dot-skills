---
title: Use a Dedicated `On-Behalf-Of` Header for Multi-Tenant Calls
impact: MEDIUM-HIGH
impactDescription: prevents acting-account confusion in platforms with thousands of tenants
tags: ops, multi-tenant, headers, connect
---

## Use a Dedicated `On-Behalf-Of` Header for Multi-Tenant Calls

When a platform makes API calls on behalf of one of its connected accounts (Stripe Connect's model), the acting account is identified by a dedicated header — `Stripe-Account: acct_X` in Stripe's case. The API key in the `Authorization` header is the platform's key; the `Stripe-Account` header narrows the call to act *as* the connected account. The two-header pattern keeps the auth credential and the acting tenant orthogonal: rotating the platform key doesn't change which accounts it can act on; switching the acting account doesn't change the key.

The alternative — passing the acting account as a query parameter, embedding it in the URL path, or shipping per-account API keys to the platform — all create variations of the same problem: it's too easy to act as the wrong account, and audit logs have to reconstruct intent from indirect signals. A dedicated header makes the intent explicit and uniform across every endpoint.

**Incorrect (acting account in URL path — defeats route caching, awkward routing):**

```text
GET /v1/accounts/acct_X/customers/cus_Y
Authorization: Basic <platform_key>
```

```text
// Every endpoint duplicates: /customers, /accounts/{id}/customers — two routing trees.
// Some endpoints reach across accounts (platform-level analytics) — URL doesn't fit.
// Switching the acting account changes every URL — refactor-heavy.
```

**Incorrect (acting account as query param — easy to lose):**

```text
GET /v1/customers/cus_Y?on_behalf_of=acct_X
Authorization: Basic <platform_key>
```

```text
// Query params disappear in some HTTP intermediaries, get dropped in proxies, get URL-encoded twice.
// Easy for a client library to forget to set on `POST` requests where the param goes... where?
// Cache keys may or may not include query params — cache pollution risk.
```

**Incorrect (per-account API key issued to the platform):**

```text
GET /v1/customers/cus_Y
Authorization: Basic <platform_key_for_acct_X>
```

```text
// Platform manages thousands of keys (one per connected account).
// Rotation is a fan-out operation.
// Audit logs show which key was used, but answering "which platform call generated this?" requires a key-to-platform table.
```

**Correct (dedicated header, key stays the platform's):**

```text
GET /v1/customers/cus_Y
Authorization: Basic <platform_key>
Stripe-Account: acct_X
```

```text
// Platform key unchanged — one credential.
// Acting account is explicit, header-only, easy to spot in logs.
// Server can validate "is this platform allowed to act on acct_X?" via Connect grant tables.
// Switching tenants is one header change, not a URL refactor.
```

**Idempotency keys are scoped per (platform-key, acting-account, key)** — see [`idem-scoped-per-account`](idem-scoped-per-account.md). A platform that submits the same idempotency key for two different acting accounts is unambiguously doing two different things.

**Audit logs include both:**

```json
{
  "request_id": "req_abc123",
  "api_key_prefix": "sk_live_PLATFORM",
  "on_behalf_of": "acct_X",
  "endpoint": "POST /v1/customers",
  "ip": "203.0.113.7",
  "timestamp": 1747699200
}
```

Lets the platform answer "which of my calls touched account acct_X yesterday?" with a single grep.

**Document the header prominently in Connect/multi-tenant docs.** This is the difference between platform calls and direct calls — without explicit docs, integrators end up grepping example code to discover it.

**The header may have different names by convention** — Stripe uses `Stripe-Account`, AWS uses `X-Amz-Target`, GitHub uses `X-GitHub-Org` for some endpoints. The name doesn't matter; the *pattern* — dedicated header for acting tenant, separate from the auth credential — does.

**Refuse calls when the platform doesn't have permission to act on the requested account.** Return `403 Forbidden` with a clear message:

```json
{
  "error": {
    "type": "invalid_request_error",
    "code": "permission_denied",
    "message": "Your API key does not have permission to act on behalf of acct_X."
  }
}
```

**Never let the header switch billing or rate-limit accounts.** The platform owns those — the `Stripe-Account` header is for *acting on* a connected account, not for billing the connected account for the call.

Reference: [Stripe Connect — direct API calls](https://docs.stripe.com/connect/authentication)
