---
title: Version in URL Path and `Stripe-Version` Header
impact: HIGH
impactDescription: prevents path-version forks on every backwards-incompatible change
tags: url, versioning, headers, compatibility
---

## Version in URL Path and `Stripe-Version` Header

The URL path carries a coarse structural version (`/v1/`) that almost never changes — it would only bump for a wholesale rewrite. Behavioral pinning happens via a dated request header (`Stripe-Version: 2024-10-28`). The two-version system separates "the shape of the API has been fundamentally redesigned" (path version) from "I want responses formatted the way they were on this date" (header version). See [`ver-dated-versions`](ver-dated-versions.md) for the dated-version scheme itself.

This split prevents the trap that single-version-in-path APIs fall into: every breaking change requires a `/v2/` path, which means duplicating every endpoint, splitting SDKs, and forcing every integrator to migrate at once. With Stripe's split, the `/v1/` path is stable for a decade while accounts roll forward through dozens of dated versions independently.

**Incorrect (only path version — every change forces /v2/):**

```text
GET /v1/customers/cus_X        # original
GET /v2/customers/cus_X        # any breaking change forks the path
GET /v3/customers/cus_X        # accumulates over time
```

```text
// SDK has to ship v1, v2, v3 clients. Documentation splits in three.
// Integrators must migrate paths to access any new endpoint.
// Routing layers have to maintain three copies of every handler.
```

**Incorrect (only header version — no structural escape hatch):**

```text
GET /customers/cus_X
Stripe-Version: 2024-10-28
```

```text
// No path version means you can never do a wholesale redesign without a domain swap.
// Discovery (looking at a URL and knowing it's "the API") loses the version cue.
```

**Correct (path version for structure, header for behavior):**

```text
GET /v1/customers/cus_X
Stripe-Version: 2024-10-28
```

```text
// `/v1/` says "this is the API generation." Stable for years.
// `Stripe-Version: 2024-10-28` says "respond as you did on this date."
// Accounts are pinned to a date at signup; per-request override via header.
```

**The path version is reserved for true generational change** — a wholesale redesign that justifies all integrators migrating. Day-to-day backwards-incompatible changes (renames, removals, behavioral shifts) belong in the dated header version, not the path.

**Connect/multi-tenant calls add a third header**: `Stripe-Account: acct_X` to act on behalf of a connected account. The path and version headers are unchanged.

Reference: [Stripe API versioning](https://stripe.com/blog/api-versioning), [Stripe versioning docs](https://docs.stripe.com/upgrades)
