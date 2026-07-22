---
title: Append as_count() explicitly when building queries outside the graph editor
tags: query, as-count, rollup, count-metrics
---

## Append as_count() explicitly when building queries outside the graph editor

This is the highest-cost default in the whole surface, because the convenience that hides it exists **only in the UI**. Datadog documents it directly: *"Queries for `COUNT` and `RATE` type metrics have the `.as_count()` modifier appended automatically in the UI, which sets the rollup method used to `sum` and disables interpolation."* Nothing appends it to a query you write into a widget definition. And the default rollup method, applied to every metric type including counts, is **`avg`**.

So `sum:checkout.orders.placed{env:prod}` submitted programmatically is rolled up by averaging: at a 5-minute rollup with one submission every 10 seconds, the graph shows the mean of thirty per-flush counts rather than their total — a number roughly thirty times too small. It renders as a smooth, believable line. There is no error, no warning, and no visual tell. The identical query typed into the graph editor shows the correct value, so a human sanity-checking it in the UI confirms a number the dashboard is not displaying.

**Incorrect (rolled up with avg — shows mean per flush, not orders placed):**

```text
sum:checkout.orders.placed{env:prod}
```

**Correct (rollup method sum, interpolation disabled, totals are totals):**

```text
sum:checkout.orders.placed{env:prod}.as_count()
```

Which modifier applies follows from the metric's in-app type, which is why `disco-read-type-and-unit-first` comes first. On a COUNT, `.as_count()` sums within the interval and gives the absolute count; `.as_rate()` sums and then divides by the interval to give a per-second figure. On a RATE, the two are inverted — `.as_count()` multiplies by the interval to recover absolute counts. On a GAUGE both are inert, so adding `.as_count()` defensively to a gauge costs nothing but achieves nothing either. Because `.as_count()` is defined against the rollup interval, the same query returns different values at different dashboard time frames; that is expected, and it is the subject of `query-rollup-changes-the-number`.

One silent path is worth knowing because it defeats the modifier: on a RATE metric with **no metadata interval configured**, Datadog skips the rescaling steps entirely and the time aggregator falls back to `AVG` instead of `SUM`. A metric submitted without an interval will therefore ignore `.as_rate()` and quietly average. If a rate metric's numbers look wrong despite the modifier, check whether its interval metadata is set.

Reference: [Rollup](https://docs.datadoghq.com/dashboards/functions/rollup/) · [Type modifiers](https://docs.datadoghq.com/metrics/custom_metrics/type_modifiers/)
