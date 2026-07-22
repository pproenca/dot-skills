---
title: Write requests as queries plus formulas, never as a q string
tags: json, formulas, deprecation, data-source
---

## Write requests as queries plus formulas, never as a q string

Almost every Datadog dashboard example older than a couple of years puts the query in a bare `q` field, so that is the shape that gets reproduced. It still parses, which is why it survives review, and it is deprecated across every widget that has it — along with the whole family of per-source variants: `apm_query`, `log_query`, `rum_query`, `security_query`, `network_query`, `event_query`, `audit_query`, `process_query`, `profile_metrics_query`. The Dashboard API marks each one *"Deprecated - Use `queries` and `formulas` instead."* Building on them forgoes formulas, aliases, cross-source arithmetic, and per-formula display options, and accumulates a migration.

**Incorrect (deprecated single-query field, no alias or formula support):**

```json
{
  "requests": [
    { "q": "sum:trace.http.request.hits{env:prod,service:checkout}.as_count()",
      "display_type": "bars" }
  ]
}
```

**Correct (named queries referenced by a formula):**

```json
{
  "requests": [{
    "formulas": [{ "formula": "query1", "alias": "Requests" }],
    "queries": [
      { "data_source": "metrics", "name": "query1",
        "query": "sum:trace.http.request.hits{env:prod,service:checkout}.as_count()" }
    ],
    "response_format": "timeseries",
    "display_type": "bars"
  }]
}
```

Each query carries a `name`; formulas reference those names, which is what makes arithmetic across data sources possible at all. `response_format` is `timeseries`, `scalar`, or `event_list` — scalar for single-value widgets like `query_value`, timeseries for graphs.

`data_source` is where a plausible guess goes wrong. It is `profiles`, not `profile_metrics` — the similar-looking `profile_metrics_query` is a deprecated *request* field, not a source value, and conflating them yields an invalid enum. The event-platform sources are `logs, spans, network, rum, security_signals, profiles, audit, events, ci_tests, ci_pipelines, incident_analytics, product_analytics, on_call_events, errors, llm_observability`. Separate branches exist with entirely different required fields for `metrics`, `cloud_cost`, `slo`, `process`, `container`, `apm_metrics`, and `apm_dependency_stats` — note that `apm_resource_stats` is deprecated in favour of `apm_metrics`. The rendered docs collapse these enums behind a "Show N more" control, so a list read off the page is likely truncated; `get_widget_reference` returns them in full.

Reference: [Create a new dashboard](https://docs.datadoghq.com/api/latest/dashboards/) · [Querying](https://docs.datadoghq.com/dashboards/querying/)
