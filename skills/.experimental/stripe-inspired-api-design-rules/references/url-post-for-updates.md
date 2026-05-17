---
title: Use POST for Updates (Not PUT or PATCH)
impact: CRITICAL
impactDescription: prevents PUT/PATCH replacement footguns and proxy-layer dropping
tags: url, http-verbs, post, updates
---

## Use POST for Updates (Not PUT or PATCH)

Updates use `POST` to the resource URL, not `PUT` or `PATCH`. The semantic is partial update — only the fields you send are modified; omitted fields are unchanged. Sending an explicit `null` clears the field. There is no separate "full replacement" verb because full replacement is rarely what integrators actually want and creates a footgun (omit a field and accidentally wipe it).

Using `POST` for both create and update has three practical benefits: (1) form-encoded bodies work identically on both — many HTTP clients and CLI tools handle `POST` bodies more reliably than `PUT`/`PATCH`; (2) only one verb to learn for mutations; (3) firewalls, proxies, and middleware that drop or rewrite `PATCH`/`PUT` (still common in some networks) don't break your API.

**Incorrect (PUT with full replacement semantics):**

```text
PUT /v1/customers/cus_X
Content-Type: application/json

{ "email": "new@example.com" }
```

```text
// PUT semantically replaces the resource — did we just wipe `name`, `phone`, `metadata`?
// Integrator has to know whether the server treats PUT as replace or merge.
// Different routing layers in the stack disagree.
```

**Incorrect (PATCH with JSON-Patch operations):**

```text
PATCH /v1/customers/cus_X
Content-Type: application/json-patch+json

[{ "op": "replace", "path": "/email", "value": "new@example.com" }]
```

```text
// JSON-Patch is expressive but obscure; most integrators have never used it.
// Form-encoded clients can't represent these operations naturally.
```

**Correct (POST with partial-update semantics):**

```text
POST /v1/customers/cus_X
Content-Type: application/x-www-form-urlencoded

email=new@example.com
```

```text
// Same verb as create — minimal cognitive load.
// Only `email` is modified; `name`, `phone`, `metadata` are untouched.
```

**Correct (POST with explicit null to clear a field):**

```text
POST /v1/customers/cus_X
Content-Type: application/x-www-form-urlencoded

phone=
```

```text
// Empty value clears `phone`. Omitting `phone` would leave it unchanged.
// The "send empty to clear" semantic is uniform across the API.
```

**Why not bring back PUT/PATCH later?** Verbs are part of the URL contract. Migrating updates from POST to PATCH after launch is a breaking change that requires versioning, parallel routing, and SDK splits. POST works forever.

Reference: [Stripe API conventions](https://docs.stripe.com/api/customers/update)
