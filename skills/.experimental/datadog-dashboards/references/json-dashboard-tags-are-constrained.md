---
title: Keep dashboard tags to five team-scoped values
tags: json, metadata, tags, permissions
---

## Keep dashboard tags to five team-scoped values

Dashboard `tags` look like the tags used everywhere else in Datadog, so they attract the same treatment — a handful of descriptive `key:value` pairs describing environment, service, and purpose. The field is narrower than that on both counts: it caps at **5 items**, and entries take the form `team:<name>` rather than arbitrary keys. Widget-level validation never sees this, because it is a property of the dashboard object, so the failure surfaces only at write time.

**Incorrect (six entries, and keys other than `team`):**

```json
{
  "tags": ["env:prod", "service:checkout", "tier:1", "owner:payments",
           "region:us-east", "purpose:oncall"]
}
```

**Correct (ownership only; scope belongs in template variables):**

```json
{
  "title": "Checkout - Prod On-Call",
  "tags": ["team:checkout"],
  "description": "Scope is selected at read time via $env and $service.",
  "layout_type": "ordered"
}
```

The scoping information that does not fit here is not lost — it belongs in template variables, where it is selectable rather than baked in, and in the title, which is what people actually search. A naming pattern carrying domain and purpose is what Datadog recommends for findability at scale, since tags alone will not carry it.

Access control has moved and the older field is the deprecated one. `is_read_only` is deprecated — the API's own note points to the Restriction Policies API instead — while `restricted_roles`, which is easy to assume was deprecated alongside it, remains the current in-object mechanism and takes role UUIDs. Restriction Policies are the v2 successor for granular control, but dashboard support there is in private beta and needs enabling per org, so `restricted_roles` is the option that works today.

```json
{
  "restricted_roles": ["8b5f2c91-3d4e-11ef-9a7b-da7ad0900001"]
}
```

Reference: [Create a new dashboard](https://docs.datadoghq.com/api/latest/dashboards/) · [Building dashboards and monitors at scale](https://www.datadoghq.com/blog/dashboards-monitors-at-scale/)
