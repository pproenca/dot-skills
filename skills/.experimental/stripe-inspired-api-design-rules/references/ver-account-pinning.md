---
title: Pin Each Account to Its First-Request Version
impact: HIGH
impactDescription: prevents existing integrators breaking when a new version ships
tags: ver, pinning, account, upgrades
---

## Pin Each Account to Its First-Request Version

When an account makes its first API request, the server records the current API version on the account. Subsequent requests use that pinned version by default — the integrator doesn't have to send `Stripe-Version` on every request, and new breaking versions shipped later don't affect them until they explicitly upgrade. Upgrades happen via the dashboard, the API itself (`POST /v1/accounts/{id}` with the new version), or per-request override via header.

This is what makes dated versioning ([`ver-dated-versions`](ver-dated-versions.md)) actually safe in practice. Without pinning, every new version would break every existing integrator on day one; with pinning, the new version is invisible to anyone not opting in. Integrators upgrade when they have time to test, the API team ships new versions whenever it makes sense, and the two cadences are independent.

**Incorrect (no pinning — version is per-request only):**

```text
# Integrator sends nothing → server defaults to "current"
POST /v1/charges
```

```text
// Server interprets "current" as the latest dated version.
// API team ships 2025-04-30 with a breaking change → integrator's response shape changes overnight.
// Every integrator must defensively pin their version on every request from day one,
// otherwise they break the next time the API ships a breaking change.
```

**Incorrect (pinning by API key — keys are rotated too often):**

```text
# Each API key pinned to a version
sk_test_X → 2024-10-28
sk_test_Y → 2025-04-30
```

```text
// Rotating an API key (security best practice) silently changes the pinned version.
// One account with multiple keys can have inconsistent behaviour across services.
```

**Correct (pinned per account, defaults applied at the edge):**

```text
# Account acct_X was created at 2024-10-28. Server records:
account.api_version = '2024-10-28'

# Request without explicit version:
POST /v1/charges
Authorization: Basic c2tfdGVzdF9YOg==

# Server resolves: use account.api_version = '2024-10-28'
```

```text
// New version 2025-04-30 ships? Account acct_X is unaffected — still pinned.
// Integrator tests 2025-04-30 in dev → upgrades acct_X via dashboard → done.
```

**Per-request override beats account pin:**

```text
POST /v1/charges
Stripe-Version: 2025-04-30

# Use 2025-04-30 just for this request, ignore account.api_version
```

Lets integrators run a new version against one endpoint before upgrading the whole account.

**Upgrade flow:**

```text
# 1. Test in dashboard with the new version
# 2. Hit the upgrade endpoint:
POST /v1/accounts/acct_X
Content-Type: application/x-www-form-urlencoded

api_version=2025-04-30

# 3. Account is now pinned to the new version; previous version stops being applied by default.
```

**Rollback window:**

> If you upgrade an account and need to roll back, you have 72 hours to revert to the previous version via the dashboard.

The rollback window is short on purpose — it's a safety net, not a long-term escape. Integrators that need more time should test thoroughly before upgrading.

**Connect platforms** pin per *platform* account by default. Connected accounts inherit the platform's version unless explicitly set differently.

**Surface the pinned version in every response** via a header so integrators can audit which version actually produced a response (especially useful when debugging unexpected payload shapes):

```text
HTTP/1.1 200 OK
Stripe-Version: 2024-10-28
```

Reference: [Stripe versioning](https://docs.stripe.com/upgrades)
