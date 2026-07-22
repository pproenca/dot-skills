---
title: Scope with template variables instead of duplicating the dashboard
tags: scope, template-variables, reuse, scaling
---

## Scope with template variables instead of duplicating the dashboard

Asked to cover six services, the reflex is six dashboards — or one dashboard with `{env:prod, service:checkout}` baked into every query, which becomes six dashboards the moment someone needs staging. Each copy then drifts independently, and a fix to the latency panel lands in one of them. Datadog's guidance is the opposite shape: *"Instead of building a new dashboard for every microservice, you can create one reusable view that adapts based on what a user selects."* A team that wants a persistent "prod view" gets a Saved View over the same dashboard, not a fork of it.

One property of template variables decides whether this works, and it bites silently: a variable's dropdown is populated **only from tags the dashboard's own widgets query**, so a `$service` variable on a board of pure metric widgets never offers values that exist only on logs. Confirm the tag key exists on every metric involved (`get_datadog_metric_context`) before promising a variable; if half the metrics lack `env`, the honest answer is that tagging needs fixing first, not that the dashboard is done. The dropdown is also windowed, which makes it look wrong on a quiet dashboard — see `disco-absence-is-not-proof`.

```json
{
  "template_variables": [
    { "name": "env", "prefix": "env", "defaults": ["prod"] },
    { "name": "service", "prefix": "service", "defaults": ["checkout"] }
  ],
  "widgets": [
    {
      "definition": {
        "type": "timeseries",
        "requests": [
          {
            "formulas": [{ "formula": "query1", "alias": "Errors/s" }],
            "queries": [
              {
                "data_source": "metrics",
                "name": "query1",
                "query": "sum:trace.http.request.errors{$env,$service}.as_count()"
              }
            ],
            "response_format": "timeseries"
          }
        ]
      }
    }
  ]
}
```

`$env` interpolates the whole `key:value` pair, which is what a scope filter wants. When you need only the value — building a composite like `env:staging-$service.value` — append `.value`, which is also the form to reach for when a prefix match is wanted, since a wildcard cannot follow a variable directly (`query-scope-syntax-does-not-mix`).

Reference: [Template Variables](https://docs.datadoghq.com/dashboards/template_variables/) · [Building dashboards and monitors at scale](https://www.datadoghq.com/blog/dashboards-monitors-at-scale/)
