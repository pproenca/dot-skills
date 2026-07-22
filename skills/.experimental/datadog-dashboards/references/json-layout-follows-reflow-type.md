---
title: Set widget layout only when reflow_type and layout_type require it
tags: json, layout, reflow, groups
---

## Set widget layout only when reflow_type and layout_type require it

Coordinates feel like a safe thing to specify — worst case they get ignored. Here they are conditionally forbidden. Whether a widget may carry a `layout` object depends on two sibling fields on the dashboard, and getting the combination wrong rejects the payload rather than degrading gracefully. The API states it directly: if `reflow_type` is `fixed`, `layout` is required; if `reflow_type` is `auto`, *"`layout` should not be set."*

| `layout_type` | `reflow_type` | Widget `layout` |
|---|---|---|
| `ordered` | `auto` (default) | Must be **omitted** |
| `ordered` | `fixed` | **Required** on every widget |
| `free` | not settable | **Required** on every widget |

Default to `ordered` + `auto` and let Datadog place widgets in array order. It reflows across screen widths, which is what makes the same dashboard readable on a laptop and a wall display, and it removes an entire class of overlap bugs. Reach for explicit coordinates only when the arrangement itself carries meaning.

```json
{
  "title": "Checkout - Prod On-Call",
  "layout_type": "ordered",
  "reflow_type": "auto",
  "widgets": [
    { "definition": { "type": "group", "layout_type": "ordered", "title": "Overview",
                      "background_color": "vivid_blue", "widgets": [] } }
  ]
}
```

A group's own `layout_type` accepts only `ordered` — a group can never lay out its children freely, whatever the parent dashboard does. Screenboard widgets cannot be placed in groups at all. A group's `widgets` array reuses the general widget union, which includes `group` itself, so nesting is expressible in the schema; whether the product accepts a nested group at write time is not documented, so test it rather than designing a deep hierarchy around it.

Two fields that a pre-2025 mental model omits entirely. Dashboards support `tabs` (up to 100), each with an `id`, a `name`, and `widget_ids` — an organisational axis above groups, useful when one board covers several audiences without becoming several boards. And `WidgetLayout` carries `is_column_break`, which forces a widget to start the second column in high-density mode; only one widget per dashboard may set it.

Widget time is likewise richer than the old fixed enum. `live_span` still works, but `time` now accepts a typed object — `{"type": "live", "value": 17, "unit": "minute"}` or `{"type": "fixed", "from": ..., "to": ...}` with epoch milliseconds — so spans the legacy enum cannot express are available. Do not assume the dashboard and widget time fields share a vocabulary: the legacy dashboard-level `global_time.live_span` enum carries eight values, while the per-widget `live_span` carries seventeen including `alert`. The modern `default_timeframe` is not an enum at all but the same typed live/fixed object.

Reference: [Create a new dashboard](https://docs.datadoghq.com/api/latest/dashboards/) · [Group widget](https://docs.datadoghq.com/dashboards/widgets/group/)
