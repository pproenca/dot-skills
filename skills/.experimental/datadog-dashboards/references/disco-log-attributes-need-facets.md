---
title: Verify a log attribute is faceted before grouping a widget by it
tags: disco, logs, facets, indexes
---

## Verify a log attribute is faceted before grouping a widget by it

Seeing `@http.status_code` in a log sample makes it look available for grouping, and it is not. In Datadog, an attribute becomes groupable only once it has been defined as a **facet**; Datadog states the dependency directly — facets are what *"allow you to manipulate your logs in… log widgets in dashboards"*. An attribute that exists on every log line but was never faceted cannot be used in a `group_by`, and the widget returns nothing rather than complaining.

This is worse than the metric case because there is **no public API that enumerates log facets**. Neither the v1 nor the v2 spec exposes one; facet discovery is a Log Explorer UI surface. So an agent cannot verify a facet the way it verifies a metric tag, and has exactly two honest options: probe with an aggregation and see whether groups come back, or ask the user which facets exist.

```json
{
  "data_source": "logs",
  "name": "query1",
  "search": { "query": "service:checkout status:error" },
  "compute": { "aggregation": "count" },
  "group_by": [{ "facet": "@http.status_code", "limit": 10 }],
  "indexes": []
}
```

Run that as a probe before committing it to a widget. Groups coming back means the facet exists; an empty result means the facet is missing, the query matches nothing, or the logs were never indexed — three different problems, all of which need the user rather than a retry with a different attribute name.

The indexing caveat is the second half of this. A log widget can only see **indexed** logs, and exclusion filters and daily quotas routinely mean that is a fraction of what was ingested: past the quota, *"logs are no longer indexed but are still available in the livetail, sent to your archives, and used to generate metrics from logs."* A panel labelled "total errors" over a sampled index is not a total. When a long-lived panel needs to count or aggregate logs, a log-based metric is the sturdier basis — it is computed from the whole ingest stream regardless of exclusion filters, and retains 15 months at 10-second granularity. Check `search_datadog_metrics` first; one may already exist, and creating one is billed as a custom metric.

Reference: [Log facets](https://docs.datadoghq.com/logs/explorer/facets/) · [Log indexes](https://docs.datadoghq.com/logs/indexes/) · [Generate metrics from logs](https://docs.datadoghq.com/logs/log_configuration/logs_to_metrics/)
