---
title: Use Dated Versions (`YYYY-MM-DD`), Not v1/v2/v3
impact: HIGH
impactDescription: prevents big-bang migrations and parallel SDK universes
tags: ver, dates, versions, compatibility
---

## Use Dated Versions (`YYYY-MM-DD`), Not v1/v2/v3

API versions are dates: `2024-10-28`, `2025-04-30`, `2026-02-15`. The version is sent in a `Stripe-Version` header (see [`url-version-in-path-and-header`](url-version-in-path-and-header.md)). Every breaking change ships as a new dated version; the previous version keeps working forever for accounts pinned to it. Date strings sort naturally, embed the release timeline, and make "is this version older than that one" trivially answerable.

The alternative — `v1`, `v2`, `v3` — forces a big-bang migration every time you bump. Every integrator has to do the work at the same time, or you support multiple `/v{n}/` URL trees forever. Dated versions let accounts upgrade independently when convenient, and the API team ships breaking changes as often as the design calls for (Stripe has shipped dozens of dated versions over the years; they've never bumped past `/v1/` in the URL).

**Incorrect (sequential integer versions — every bump is a fork):**

```text
GET /v1/customers/cus_X           # original
GET /v2/customers/cus_X           # any breaking change
GET /v3/customers/cus_X           # accumulates over time
```

```text
// SDK ships three clients: SDKv1, SDKv2, SDKv3. Integrators choose at upgrade time.
// Every endpoint duplicated across v1, v2, v3 handlers.
// Documentation splits in three; cross-referencing breaks.
// Migrating from v1 to v2 is a project; every consumer must complete it before v1 is sunset.
```

**Incorrect (semver versions — same problems plus version-bump theatre):**

```text
GET /api/v1.4.2/customers/cus_X
GET /api/v2.0.0/customers/cus_X
```

```text
// Every change forces a version-bump conversation: "is this a minor or a major?"
// Patch and minor distinctions don't map onto API surface changes.
// Three-segment versions don't sort lexically without library help.
```

**Correct (dated versions in a header):**

```text
GET /v1/customers/cus_X
Stripe-Version: 2024-10-28
```

```text
// Same URL works for every version. SDK is one codebase that switches behaviour by version.
// New dated version every time a breaking change ships — granular, not bundled.
// Accounts upgrade independently when their integration is ready.
// Date strings sort lexically: "2024-10-28" < "2025-04-30" — easy to reason about.
```

**Date semantics:**
- Date = the day the version was shipped, in UTC
- Format = `YYYY-MM-DD` exactly (zero-padded, dashes, ISO 8601 date)
- Once published, a version is **immutable** — you can't retroactively change what `2024-10-28` means

**Per-request version override:**

```text
POST /v1/charges
Stripe-Version: 2025-04-30           # explicitly target this version
```

Lets integrators test a newer version against a single endpoint before flipping their account-wide pin.

**Account pinning** ([`ver-account-pinning`](ver-account-pinning.md)) means accounts default to a version without sending the header on every request — the header is only needed for overrides.

**Date the version when you ship it, not when you start planning it.** Versions named after planned changes (`2025-q3-redesign`) lose meaning and become land-mines for sorting.

Reference: [Stripe API versioning](https://stripe.com/blog/api-versioning)
