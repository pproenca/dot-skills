---
title: Alias every formula and leave units out of the title
tags: layout, titles, units, aliases
---

## Alias every formula and leave units out of the title

"Number of requests per second (req/s)" is a title that says three things the widget already shows. Datadog renders a metric's unit on the axis automatically whenever the metric has one configured, so writing it into the title duplicates it, and the axis already establishes that the y-value is a quantity. The integration standard is direct on all three points: *"do not indicate units in graph titles"*, do not write "number of…", and do not repeat the integration or service name in every widget when the dashboard is already scoped to it.

```text
Number of checkout requests per second (req/s)   ->  Requests
Checkout service p95 latency in milliseconds     ->  p95 latency
Count of errors for the checkout service         ->  Errors
```

The room this frees is worth spending on the part that is not obvious: which of several similar series a line is. An unaliased formula labels itself with the raw query, so a legend reads `sum:trace.http.request.errors{env:prod,service:checkout}.as_count()` instead of `Errors`. Aliasing every formula is a standing rule, not a polish step.

```json
{
  "formulas": [
    { "formula": "query1", "alias": "5xx" },
    { "formula": "query2", "alias": "4xx" },
    { "formula": "query1 / query3", "alias": "5xx rate" }
  ]
}
```

Titles are sentence case at widget level and Title Case at group level, and lead with the most important word so a scan down the left edge works.

A missing unit is a data-quality signal rather than a formatting gap. When a metric renders bare numbers, the fix is to set the unit on the metric — which corrects it everywhere in the org — not to paste a `custom_unit` string onto one widget. Datadog notes that a widget-level unit override *"is not an alternative for assigning units to your data"*. `custom_unit` earns its place for genuinely widget-local quantities, such as a computed ratio expressed as a percentage, where no underlying metric owns the unit.

Reference: [Datadog integration dashboard guidelines](https://datadoghq.dev/integrations-core/guidelines/dashboards/) · [Widget configuration](https://docs.datadoghq.com/dashboards/widgets/configuration/) · [Unit override](https://docs.datadoghq.com/dashboards/guide/unit-override/)
