---
title: Pick the display type from the shape of the metric
tags: layout, display-type, timeseries, axes
---

## Pick the display type from the shape of the metric

`display_type` gets left at whatever came out first, usually `line`, and lines are wrong for two common cases. A discrete count rendered as a line implies continuity between samples that does not exist — the value did not glide from 40 to 60, it was 40 then 60. A volume that composes into a total rendered as separate lines makes the reader add them up by eye. Datadog's integration standard fixes defaults for exactly this:

```text
area   - volume metrics that stack into a meaningful total
bars   - counts and other discrete per-interval quantities
line   - multiple groups compared against each other; the general default
```

```json
{
  "type": "timeseries",
  "title": "Requests by status",
  "requests": [
    { "display_type": "bars",
      "formulas": [{ "formula": "query1", "alias": "2xx" }],
      "queries": [{ "data_source": "metrics", "name": "query1",
                    "query": "sum:trace.http.request.hits{$env,$service,http.status_class:2xx}.as_count()" }],
      "response_format": "timeseries" },
    { "display_type": "line",
      "on_right_yaxis": true,
      "formulas": [{ "formula": "query2", "alias": "p95 latency" }],
      "queries": [{ "data_source": "metrics", "name": "query2",
                    "query": "p95:trace.http.request{$env,$service}" }],
      "response_format": "timeseries" }
  ],
  "yaxis": { "include_zero": true, "scale": "linear" },
  "right_yaxis": { "include_zero": false, "scale": "linear" }
}
```

Two axes on one widget is how a rate and a latency get correlated without forcing the reader across two panels; `on_right_yaxis` is set per request, and the widget carries a separate `right_yaxis` config. Use it when the correlation is the point, not to save space — two unrelated series sharing a frame reads as a relationship that is not there.

Axis configuration carries meaning that is easy to give away accidentally. `include_zero` defaults on, and turning it off magnifies noise into what looks like a crisis; leave it on for anything an on-call engineer reads under pressure. `scale` is not a fixed four-value enum: alongside `linear`, `log`, and `sqrt` it accepts a parameterised `pow` form such as `pow2` or `pow0.5`.

Datadog's standard also asks for legends on every graph and aligned x-axes between adjacent graphs, both for the same reason — a reader comparing two panels should not have to check whether the comparison is valid.

Reference: [Datadog integration dashboard guidelines](https://datadoghq.dev/integrations-core/guidelines/dashboards/) · [Timeseries widget](https://docs.datadoghq.com/dashboards/widgets/timeseries/)
