---
title: Validate and smoke-test each widget before upserting the dashboard
tags: ship, mcp, validation, workflow
---

## Validate and smoke-test each widget before upserting the dashboard

The tempting shape is to assemble the whole dashboard from memory and upsert it once. That defers every error to a single write, where a schema rejection names one field and hides the rest, and where a widget that is structurally valid but returns nothing is not reported at all — it ships, renders blank, and is discovered by a human days later. Both failures are avoidable before the write, using tools that exist for exactly this.

Run the sequence rather than the single call:

```text
1. search_datadog_services / search_datadog_metrics   what exists here
2. get_datadog_metric_context                          does this metric carry these tags
3. get_datadog_metric                                  does this query return points
4. get_widget_reference                                current schema for the types in use
5. validate_dashboard_widget                           per widget, before assembling
6. upsert_datadog_dashboard                            omit the id to create, pass it to update
```

Steps 3 and 5 are the two that get skipped and the two that pay. A query returning no points during discovery will return no points on the dashboard; catching it costs one call. `validate_dashboard_widget` exists *"to check widget JSON before passing it to `upsert_datadog_dashboard`"*, and validating per widget localises a failure to the widget that caused it.

```json
{
  "tool": "validate_dashboard_widget",
  "arguments": {
    "widget": {
      "definition": {
        "type": "timeseries",
        "title": "Requests",
        "requests": [{
          "formulas": [{ "formula": "query1", "alias": "Requests" }],
          "queries": [{ "data_source": "metrics", "name": "query1",
                        "query": "sum:trace.http.request.hits{$env,$service}.as_count()" }],
          "response_format": "timeseries",
          "display_type": "bars"
        }]
      }
    }
  }
}
```

`get_widget_reference` returns schemas *plus* building guidance covering query patterns and known pitfalls, current at call time — which beats any copy that could be written down here, and is why this skill does not restate widget schemas. `ask_widget_expert` handles the narrower questions those two do not settle. The widgets toolset adds `verify_widget_data`, which checks that a widget actually returns data over the last hour, and `swap_widget_type`, which converts a widget to another visualization while preserving its queries — supported between `timeseries`, `query_value`, `toplist`, `query_table`, `treemap`, `sunburst`, `distribution`, `heatmap`, and `geomap`.

Take argument names from the server's advertised tool schema rather than from the shapes shown here; the docs publish tool descriptions and permissions, not input schemas, so the arguments in this skill's examples are illustrative of the sequence, not a contract.

`upsert_datadog_dashboard` creates when no id is supplied and updates when one is, so re-running a build with the id captured from the first call is idempotent rather than duplicating the board. Fair-use limits apply: 50 requests per 10 seconds, 50,000 tool calls a month — comfortable for authoring, worth knowing before looping over hundreds of widgets.

Reference: [Datadog MCP Server Tools](https://docs.datadoghq.com/mcp_server/tools/) · [Datadog MCP Server](https://docs.datadoghq.com/mcp_server/)
