---
title: Read a metric's type and unit before choosing how to aggregate it
tags: disco, metadata, metric-types, units
---

## Read a metric's type and unit before choosing how to aggregate it

A metric's in-app type is not inferable from its name, and it decides the two things you are about to get wrong: whether the query needs `.as_count()` (`query-append-as-count-explicitly`) and whether percentiles are available at all (`query-percentiles-require-distributions`). `orders.placed` sounds like a count; if it was submitted through DogStatsD's `increment()` it is stored in-app as a **RATE**, and if it was submitted through an Agent check's `self.rate()` it is stored as a **GAUGE**. The submission type and the in-app type differ often enough that guessing from the name or from how the code looks is unreliable.

The unit matters for a different reason: when a metric has a unit set, Datadog renders it on the axis automatically, which is why writing it into the widget title duplicates it (`layout-let-datadog-render-units`). A metric with no unit configured renders bare numbers, and that is a data-quality finding worth surfacing rather than papering over with a `custom_unit` string.

```json
{
  "tool": "get_datadog_metric_context",
  "arguments": { "metric": "checkout.orders.placed" }
}
```

Read three fields off the response and let them drive the query:

```text
type: count | rate      -> append .as_count() or .as_rate(); space aggregator sum
type: gauge             -> avg/min/max are meaningful; .as_count() is a no-op
type: distribution      -> p50/p95/p99 available only if percentiles were enabled
unit set                -> leave it out of the title, Datadog renders it
unit absent             -> report it; a custom_unit label hides the gap rather than fixing it
```

Changing a metric's type after the fact is not a repair — Datadog warns that it *"causes data submitted before the type change to behave incorrectly"*, and the change applies to every dashboard and monitor in the org, not just the one you are building.

Reference: [Metric types](https://docs.datadoghq.com/metrics/types/) · [Type modifiers](https://docs.datadoghq.com/metrics/custom_metrics/type_modifiers/) · [Metrics Summary](https://docs.datadoghq.com/metrics/summary/)
