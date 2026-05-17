---
title: Prefix API Keys with Scope and Mode (`sk_live_`, `pk_test_`, `rk_`)
impact: HIGH
impactDescription: prevents production keys leaking into client code and enables secret-scanning
tags: ops, auth, api-keys, secrets
---

## Prefix API Keys with Scope and Mode (`sk_live_`, `pk_test_`, `rk_`)

API keys carry visible prefixes that encode both their **scope** (secret / publishable / restricted) and **mode** (live / test): `sk_live_...`, `sk_test_...`, `pk_live_...`, `pk_test_...`, `rk_live_...`, `rk_test_...`. The prefix is part of the key itself, never inferred from headers or endpoints. This is the same opaque-prefix pattern as resource IDs ([`resource-prefixed-string-ids`](resource-prefixed-string-ids.md)), applied to credentials — and it's the single most effective defence against the leaked-production-key class of incident.

Visible prefixes enable secret-scanning across the entire ecosystem: GitHub's secret-scanning service blocks commits containing `sk_live_*`; Discord, Slack, and similar tools can warn when keys are pasted in messages; CI linters reject build logs containing live keys. None of this works if your keys are bare base64 strings indistinguishable from API tokens, JWTs, or random data.

**The key prefix taxonomy:**

| Prefix | Scope | Mode | Visibility | Use |
|--------|-------|------|------------|-----|
| `sk_live_` | secret | live | server-only | full-access production calls |
| `sk_test_` | secret | test | server-only | full-access development calls |
| `pk_live_` | publishable | live | client-safe | front-end tokenisation (e.g., Stripe.js in browser) |
| `pk_test_` | publishable | test | client-safe | front-end tokenisation in development |
| `rk_live_` | restricted | live | server-only | scoped permissions (least-privilege) |
| `rk_test_` | restricted | test | server-only | scoped permissions in development |

**Incorrect (bare keys — no information, no scanning):**

```text
Authorization: Bearer JhBfg7kKlmPq3RxYsTzVwXyZ12345678
```

```text
// Indistinguishable from any other API token.
// GitHub secret-scanning can't pattern-match it.
// A developer who finds this in a log can't tell if it's live, test, secret, or publishable.
// Accidentally committed to a public repo: hours of credential rotation, audit, customer notifications.
```

**Incorrect (mode encoded outside the key — easy to mismatch):**

```text
Authorization: Bearer JhBfg7kKlmPq3RxYsTzVwXyZ
Stripe-Mode: live
```

```text
// Mode and key carried in different headers — easy for a copy-paste to lose the mode header
// and accidentally hit the live API with what was meant as a test key (or vice versa).
// Can't scan logs for "live keys" — would have to correlate header presence.
```

**Correct (prefixed keys, all-in-one):**

```text
Authorization: Basic c2tfbGl2ZV9hYmMxMjM6
# Decoded: sk_live_abc123:
# Key is sk_live_abc123 — instantly identifies as secret + live mode
```

```text
// The first 8 chars tell you: secret key (sk_), live mode (live_).
// GitHub's scanner blocks the commit. Slack DLP flags the message.
// Developer reading logs knows immediately what they're looking at.
```

**Restricted keys (`rk_`) for least-privilege access:**

Restricted keys carry a subset of permissions — e.g., "read-only on Customers, write on PaymentIntents". This is the right key class for microservices that only need narrow access, replacing the "full secret key everywhere" anti-pattern:

```text
rk_live_X — can read /v1/customers, can write /v1/payment_intents, nothing else
```

```text
// Limits blast radius if the key leaks.
// Audit logs show exactly which services have which permissions.
// Rotating one service's key doesn't disrupt others.
```

**Distinguishable test vs live in every log line:**

```text
[2026-05-17T10:30:00Z] api_request key=sk_test_abc... → 200 OK
[2026-05-17T10:30:01Z] api_request key=sk_live_xyz... → 200 OK
```

```text
// Mode is grep-able from any log: grep 'sk_live_' for production-only events.
// Mistaken live-mode calls from a test script are immediately visible.
```

**Document the prefix scheme publicly** so secret-scanning ecosystems can ingest the pattern. Stripe publishes its prefixes; the prefixes become a standard target for tools like GitHub's secret-scanning, gitleaks, trufflehog.

**Never log or print the full key.** Truncate to prefix + 4 chars: `sk_live_abc...wxyz`. The prefix retains all the diagnostic value; the truncation prevents log-based key exfiltration.

**Rotate via key-pairs**, not in-place. Issue a new key, deploy it, revoke the old key. The prefix scheme makes the rotation auditable (both keys are visibly different strings).

Reference: [Stripe authentication](https://docs.stripe.com/api/authentication), [Stripe restricted keys](https://docs.stripe.com/keys#limit-access)
