---
title: Look up the wire type string rather than deriving it from the widget's name
tags: json, widget-types, schema, naming
---

## Look up the wire type string rather than deriving it from the widget's name

Most widget `type` values are the snake_case of the UI label, which makes the exceptions dangerous: the pattern holds often enough to be trusted, then fails silently on the ones that matter. A validation error reports that the type is invalid; it does not tell you that the widget you want is spelled something else entirely, so the recovery is guessing rather than correcting.

These are the divergences, all verified against the published schemas:

| UI name | Wire `type` | Note |
|---|---|---|
| Pie Chart | `sunburst` | No `pie_chart` type exists at all — a flat pie is a one-ring sunburst |
| Table | `query_table` | Not `table` |
| Service Summary | `trace_service` | |
| Monitor Summary | `manage_status` | |
| Split Graph | `split_group` | The doc URL slug is `split_graph`; the type is not |
| Service Map | `servicemap` | No underscore, and superseded by `topology_map` with `data_source: service_map` |
| Retention | `cohort` or `retention_curve` | Two types for one UI widget; neither appears on its own doc page |
| List | `list_stream` | Supersedes the still-valid legacy `log_stream`, `event_stream`, `event_timeline` |

Rather than memorising these, ask the server. `get_widget_reference` returns current schemas and building instructions for widget types, which is authoritative in a way a copied table cannot stay:

```json
{
  "tool": "get_widget_reference",
  "arguments": { "widget_types": ["sunburst", "query_table", "manage_status"] }
}
```

Call it before generating widgets, not after a rejection. It costs one round trip and removes the entire class of schema guesswork — enum values, required fields, and the query shapes each type accepts.

Three widget types have no published JSON schema anywhere reachable: Cost Summary, Budget Summary, and Cloudcraft Diagram. They are absent even from the group widget's nested definition, so their type strings cannot be verified from documentation. Do not guess them — build those in the UI and export, or ask `ask_widget_expert`.

Reference: [Pie Chart widget](https://docs.datadoghq.com/dashboards/widgets/pie_chart/) · [Group widget](https://docs.datadoghq.com/dashboards/widgets/group/) · [Datadog MCP Server Tools](https://docs.datadoghq.com/mcp_server/tools/)
