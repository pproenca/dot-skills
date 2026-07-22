---
title: Search for an existing dashboard before authoring a new one
tags: scope, reuse, presets, powerpacks
---

## Search for an existing dashboard before authoring a new one

Every Datadog integration ships a preset dashboard, and there are over a thousand integrations. Hand-authoring a Postgres board from scratch reproduces work that already exists, with worse metric selection — the preset was written by the people who wrote the check and knows which of `postgresql.*` matters. Datadog's own instruction is blunt: *"The fastest way to onboard widgets relevant to your data is to clone a dashboard from the preset list."*

The trap is that presets are invisible to enumeration. `GET /api/v1/dashboard` documents the exclusion explicitly — *"This query will only return custom created or cloned dashboards. This query will not return preset dashboards."* An agent that lists dashboards, sees no Postgres board, and concludes none exists is wrong.

```json
{
  "tool": "search_datadog_dashboards",
  "arguments": { "query": "postgres" }
}
```

Treat an empty result from that search as inconclusive rather than as proof, because the tool may inherit the same preset exclusion as the endpoint beneath it. The dependable check is the Dashboard List UI, where presets are listed and labelled **Preset**; when a search comes back empty, ask the user to look there before building from scratch.

Cloning produces an **unlinked** copy — later changes to the preset do not propagate, which is what you want for a board you intend to edit. When the goal is the opposite, a widget set that stays in sync across many dashboards, that is a Powerpack: *"Updates to custom Powerpacks are synced to all its Powerpack instances."* Use one when a platform team owns a technology horizontally (the Kafka panel set, the golden-signals block) and product teams assemble those blocks into full-stack views. Powerpack descriptions cap at 80 characters and tags are plain strings (`kafka`, `k8s`), not `key:value` pairs.

```json
{
  "definition": {
    "type": "powerpack",
    "powerpack_id": "3f2b1c8a-7d4e-4f91-b0a2-5c6d8e9f0a1b",
    "template_variables": {
      "controlled_externally": [{ "name": "env", "prefix": "env", "values": ["prod"] }]
    }
  }
}
```

Reference: [Widgets](https://docs.datadoghq.com/dashboards/widgets/) · [Getting Started with Dashboards](https://docs.datadoghq.com/getting_started/dashboards/) · [Powerpacks best practices](https://docs.datadoghq.com/dashboards/guide/powerpacks-best-practices/) · [Get all dashboards](https://docs.datadoghq.com/api/latest/dashboards/)
