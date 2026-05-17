---
title: Use Prefixed String IDs for Every Resource
impact: CRITICAL
impactDescription: prevents type confusion in logs, support, and codegen
tags: resource, identifiers, prefixes, debuggability
---

## Use Prefixed String IDs for Every Resource

Every resource ID should carry a short prefix identifying the resource type — `cus_`, `ch_`, `pi_`, `sub_`, `in_`, `pm_`. Bare UUIDs and numeric IDs are indistinguishable in logs, dashboards, and support tickets, and they prevent any system (yours, integrators', secret-scanners') from validating that an ID belongs to the expected resource type. Once the API ships without prefixes, retrofitting them is a breaking change because every existing ID must remain valid forever.

Use short prefixes for high-traffic resources (2-4 chars: `cus_`, `ch_`, `pi_`) and resource-name-derived prefixes for domain-specific objects (≤7 chars excluding the underscore: `sub_`, `seti_`, `disp_`). Each prefix must be unique across the API.

**Incorrect (bare UUID — opaque, untyped):**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "amount": 2000
}
```

```text
// Cannot tell from the ID alone: customer? charge? subscription?
// Support engineer must query each table to find which resource this is.
```

**Correct (typed prefix — recognisable at a glance):**

```json
{
  "id": "ch_3MqZlPLkdIwHu7ix0slN3S9y",
  "amount": 2000
}
```

```text
// `ch_` instantly identifies this as a Charge.
// Logs, dashboards, and secret-scanners can route by prefix.
// Codegen tools and runtime checks can validate type from the ID.
```

**When NOT to follow this pattern:**
- Internal-only objects never exposed across the API boundary may use bare UUIDs.
- Foreign-system IDs (Stripe charge ID stored as a foreign key on your `Order`) keep the foreign prefix.

**The prefix is the *only* part of the ID that has structure.** Everything after the prefix is opaque — see [`resource-opaque-ids`](resource-opaque-ids.md). The same pattern applies to API keys ([`ops-prefixed-api-keys`](ops-prefixed-api-keys.md)): visible scope/mode prefix, opaque body.

Reference: [Stripe API conventions — IDs](https://docs.stripe.com/api/charges/object), [Designing APIs for Humans: Object IDs (Paul Asjes, Stripe)](https://dev.to/stripe/designing-apis-for-humans-object-ids-3o5a)
