---
title: Choose the widget from the question, not from habit
tags: widget, visualization, selection, query-value
---

## Choose the widget from the question, not from habit

The timeseries is the default for everything, and it answers exactly one question: how did this change over time. "Are we inside our error budget", "which service is worst right now", and "did this week beat last week" are not that, and rendering them as a line leaves the reader doing the comparison by eye — the work the widget was supposed to do. Most of the mapping is obvious once the question is stated plainly; three calls are not.

**A single current value wants `query_value`, and a bare number is half a widget.** This is the one that gets under-configured rather than mis-chosen: a number with no threshold and no trend tells the reader nothing about whether to act. Datadog's own integration standard asks for a sparkline behind it rather than an empty tile, and conditional formatting is what turns a value into a verdict.

```json
{
  "type": "query_value",
  "title": "Checkout error rate",
  "precision": 2,
  "timeseries_background": { "type": "area" },
  "requests": [{
    "formulas": [{ "formula": "query1 / query2" }],
    "queries": [
      { "data_source": "metrics", "name": "query1",
        "query": "sum:trace.http.request.errors{$env,$service}.as_count()" },
      { "data_source": "metrics", "name": "query2",
        "query": "sum:trace.http.request.hits{$env,$service}.as_count()" }
    ],
    "response_format": "scalar",
    "conditional_formats": [
      { "comparator": ">", "value": 0.05, "palette": "white_on_red" },
      { "comparator": ">", "value": 0.01, "palette": "black_on_light_yellow" },
      { "comparator": "<=", "value": 0.01, "palette": "white_on_green" }
    ]
  }]
}
```

**A period-over-period question wants `change`, not two timeseries.** It computes the delta directly through `change_type` (`absolute` or `relative`) and `compare_to` (`hour_before`, `day_before`, `week_before`, `month_before`), so "how much has this moved since last week" is read rather than inferred from two overlaid lines.

**`toplist` versus `bar_chart` has a documented rule**, which is worth having because both are categorical and the choice otherwise looks arbitrary: *"Use the bar chart when visual comparison across categories matters more than reading exact tag values. Use the top list to prioritize label readability (such as long tag names) or need a ranked list format."* The vertical orientation also suits wide, short dashboard slots.

A `wildcard` widget exists for visualizations nothing else covers, and Datadog frames it as a last resort — *"Datadog recommends using an existing dashboard widget to meet your use case."* Reaching for it early usually means the question has not been narrowed enough.

Reference: [Query Value widget](https://docs.datadoghq.com/dashboards/widgets/query_value/) · [Change widget](https://docs.datadoghq.com/dashboards/widgets/change/) · [Bar Chart widget](https://docs.datadoghq.com/dashboards/widgets/bar_chart/) · [Datadog integration dashboard guidelines](https://datadoghq.dev/integrations-core/guidelines/dashboards/)
