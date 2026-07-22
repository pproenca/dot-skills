---
title: Confirm every metric name against the account before querying it
tags: disco, metrics, discovery, mcp
---

## Confirm every metric name against the account before querying it

Metric names are conventional, not standardized, so a plausible name is easy to generate and almost never right. `app.request.latency`, `service.errors.total`, `checkout.orders.count` all look like real Datadog metrics; whether any of them exists depends on what this org's agents and libraries actually submit. A query naming a metric that does not exist does not error — it returns an empty series, and the widget renders as a blank graph indistinguishable from a healthy period with no traffic. Nothing in the build loop catches it, so the dashboard ships and is trusted until someone notices the panel has been flat since creation.

Treat the metric name as an input to be looked up, never as a thing to be recalled. Search the account first, then confirm the specific metric carries the tags you intend to filter and group by.

**Incorrect (renders an empty graph, never errors):**

```json
{
  "data_source": "metrics",
  "name": "query1",
  "query": "avg:app.request.latency{env:prod}"
}
```

**Correct (name and tags returned by discovery before the query was written):**

```json
[
  { "tool": "search_datadog_metrics", "arguments": { "query": "checkout latency" } },
  { "tool": "get_datadog_metric_context", "arguments": { "metric": "trace.http.request" } },
  { "tool": "get_datadog_metric",
    "arguments": { "query": "p95:trace.http.request{env:prod,service:checkout}" } }
]
```

`get_datadog_metric_context` is the one that earns its call: it returns the metric's metadata **and its available tags and tag values**, so it settles in a single lookup whether `env:prod` matches anything and whether `by {service}` will split. It also surfaces the tags and aggregations already used against this metric on real dashboards, monitors, and explorer queries — a far better prior for choosing a `by {…}` clause than reasoning from the metric's name, because it reflects the groupings humans found useful on this data. The final `get_datadog_metric` is a smoke test: a query that returns no points during discovery will return no points on the dashboard, and finding that out now costs one call instead of a review cycle.

APM is the one family where names are predictable, because Datadog generates them: `trace.<SPAN_NAME>.hits`, `trace.<SPAN_NAME>.errors`, `trace.<SPAN_NAME>.apdex`, and `trace.<SPAN_NAME>` itself as the latency distribution. Even there, `<SPAN_NAME>` is application-specific and still needs looking up.

Reference: [Datadog MCP Server Tools](https://docs.datadoghq.com/mcp_server/tools/) · [APM metrics namespace](https://docs.datadoghq.com/tracing/metrics/metrics_namespace/)
