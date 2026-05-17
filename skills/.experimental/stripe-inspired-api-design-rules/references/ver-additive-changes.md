---
title: Define What Counts as a Backwards-Compatible Change
impact: HIGH
impactDescription: prevents breaking changes from shipping by accident
tags: ver, compatibility, additive, breaking-changes
---

## Define What Counts as a Backwards-Compatible Change

Backwards-compatible changes ship without a new dated version. Backwards-incompatible changes require a new version and a [version-change module](ver-version-change-modules.md). The line between the two has to be explicit and documented — otherwise the API team ships breaking changes thinking they're additive (`adding a `null` value to an enum`), and integrators get burned. Stripe documents this list exhaustively.

The discipline is the foundation of dated versioning's practical safety. If you can't tell whether a change needs a version bump, you can't honour the pinning promise — accounts on `2024-10-28` will start getting unexpected behaviour.

**Backwards-compatible (no version bump required):**

| Change | Why it's compatible |
|--------|---------------------|
| Adding new endpoints or resources | Existing clients don't call new endpoints |
| Adding new optional request parameters | Existing requests don't send the param |
| Adding new response fields | Existing clients ignore unknown fields |
| Adding new event types (webhooks) | Clients must tolerate unknown types — see [`ver-tolerate-unknown`](ver-tolerate-unknown.md) |
| Adding new enum values (where allowed) | Clients must tolerate unknown enum values — document this requirement upfront |
| Reordering response fields | JSON objects are unordered by spec |
| Changing the length or format of opaque strings (IDs, error messages) | Strings are documented as opaque ([`resource-opaque-ids`](resource-opaque-ids.md)) |
| Adding or removing fixed ID prefixes (e.g., `ch_`) | Prefixes are not part of the identifier contract |
| Renaming or restructuring internal error messages | `message` is human-readable, not machine-readable |

**Backwards-incompatible (requires a new dated version + version-change module):**

| Change | Why it's breaking |
|--------|-------------------|
| Removing an endpoint, resource, or field | Existing clients call/read it |
| Renaming a field | Existing clients look up the old name |
| Changing a field's type (`string` → `integer`) | Existing clients parse with the old type |
| Changing the meaning of an existing value | E.g., `status: "active"` previously meant X, now means X+Y |
| Replacing a boolean with an enum | E.g., `verified: true/false` → `status: "verified" \| "pending" \| "rejected"` |
| Tightening validation rules | Requests that used to succeed now 400 |
| Changing pagination, ordering, or filtering semantics | Existing iteration code now skips or duplicates |
| Changing what triggers a webhook event | Existing handlers no longer fire when expected |
| Changing HTTP status codes for existing errors | Client retry logic changes behaviour |

**Borderline cases — document the policy upfront:**

- **Adding required request parameters**: Breaking (existing requests now 400). Sometimes shipped as breaking-but-opt-in: the new param is only required when a new optional param is sent.
- **Adding fields to webhook payloads**: Additive (new field on the payload). But if a downstream integrator's schema validation rejects unknown fields, it'll appear breaking — document the "tolerate unknown fields" requirement explicitly.
- **Fixing a bug**: Almost always breaking if anyone was relying on the broken behaviour. Treat as a version-bump unless you can prove no integrator depended on the bug.

**Incorrect (shipping a breaking change as additive):**

```diff
- "verified": true
+ "status": "verified"
```

```text
// Field rename. Existing clients that read `verified` get `undefined`.
// Integrators wake up to broken integrations with no warning.
// "But we left `verified` in for now" — leaves dead fields cluttering responses forever,
// and you'll still face the same break when you eventually remove them.
```

**Correct (rename via dated version + transformer):**

```text
# Version 2024-10-28 (current behaviour)
{ "verified": true }

# Version 2025-04-30 (new shape)
{ "status": "verified" }

# Server has a version-change module:
#   when responding to a 2024-10-28-pinned account, transform `status` → `verified` for output.
#   when 2024-10-28-pinned account sends `verified` in a request, transform → `status`.
```

**Document the policy** prominently — a public "API compatibility policy" page that integrators can link to is more useful than a one-line "we follow semantic versioning":

> The following types of changes are considered backwards-compatible and may ship at any time without a version bump: [list]. The following changes require a new dated version: [list]. Adding new enum values is backwards-compatible — clients must tolerate unknown values.

Reference: [Stripe upgrades — what changes require a new version](https://docs.stripe.com/upgrades)
