---
title: Build log, span, and RUM queries as structured objects
tags: query, logs, spans, event-platform
---

## Build log, span, and RUM queries as structured objects

Metric queries are a single string, so the habit transfers and produces `"query": "count:logs{service:checkout}"` — which is not a form Datadog accepts for logs. Every event-platform source (`logs`, `spans`, `rum`, `security_signals`, `profiles`, `audit`, `events`, `ci_tests`, `ci_pipelines`, `incident_analytics`, `product_analytics`, `on_call_events`, `errors`, `llm_observability`, `network`) takes a **structured object**: a `search` string in the explorer's own syntax, a `compute` describing the aggregation, and an optional `group_by`. The split matters because these are separate `oneOf` branches with different required fields, not one shape with optional extras.

```json
{
  "data_source": "logs",
  "name": "query1",
  "search": { "query": "service:checkout status:error" },
  "compute": { "aggregation": "pc95", "metric": "@duration", "interval": 60000 },
  "group_by": [{ "facet": "@http.status_code", "limit": 10,
                 "sort": { "aggregation": "count", "order": "desc" } }],
  "indexes": []
}
```

Three details in that object are the ones that go wrong. `compute.interval` is in **milliseconds**, while metric `.rollup()` is in seconds — writing `60` here asks for 60ms buckets and is a silent thousandfold error. Percentiles are spelled `pc95`, not `p95`, and only the fixed set `pc75, pc90, pc95, pc98, pc99` exists, with no arbitrary percentile as distributions allow. And `indexes: []` queries all indexes; naming one restricts to it, which is a common way to accidentally halve a count.

The full aggregation set is `count, cardinality, median, pc75, pc90, pc95, pc98, pc99, sum, min, max, avg`. Anything other than `count` requires `compute.metric` naming the attribute to aggregate.

What these queries measure is the **indexed** population, which is not the same as traffic. Spans are retained per retention filter with a percentage sampled uniformly, and Datadog draws a sharp line between contexts: *"APM queries in dashboards and notebooks are based on all indexed spans. APM queries in monitors are based on spans indexed by custom retention filters only."* So a span-based panel and a monitor over the same query see different populations. When a widget needs to represent real throughput rather than a sample, use the `trace.*` metrics instead — those are *"calculated based on 100% of the application's traffic, regardless of any trace ingestion sampling configuration"*.

```text
sum:trace.http.request.hits{env:prod,service:checkout}.as_count()
```

Reference: [Create a new dashboard](https://docs.datadoghq.com/api/latest/dashboards/) · [Trace retention](https://docs.datadoghq.com/tracing/trace_pipeline/trace_retention/) · [APM metrics namespace](https://docs.datadoghq.com/tracing/metrics/metrics_namespace/)
