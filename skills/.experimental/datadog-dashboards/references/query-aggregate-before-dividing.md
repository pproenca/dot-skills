---
title: Aggregate both sides before dividing them into a ratio
tags: query, formulas, ratios, error-rate
---

## Aggregate both sides before dividing them into a ratio

An error rate looks like a division and gets written as one: errors over requests, two queries and a formula. Without `.as_count()` on both operands the result is wrong, and it is wrong differently depending on what the widget does with the series.

On a timeseries, each operand is rolled up with `avg` and interpolated independently before the division, so a numerator reported only by the hosts that erred is divided by a denominator interpolated across the whole fleet. The ratio is then distorted by an amount that depends on reporting gaps rather than on the error rate — off by enough to matter, but never absurd enough to notice. Where the formula is reduced to a single value — a `query_value` or `toplist` whose aggregator sums the series, and monitors, where Datadog documents the case explicitly — the failure is louder: per-interval ratios get summed instead of totals being divided, and the documented worked example sums five per-minute ratios to **1.5** against a true ratio of **0.3**. A 150% error rate is at least visibly impossible; the timeseries version is the one that gets believed.

`.as_count()` on both operands fixes both cases. It sets the rollup method to `sum`, disables interpolation, and switches the evaluation path so the counts are aggregated first and the division happens on the totals — which is the arithmetic that was intended. This is the same modifier as `query-append-as-count-explicitly`, earning its place for a second reason: there it was the rollup method, here it is the order of aggregation relative to the formula.

**Incorrect (sums per-interval ratios — can exceed 1.0):**

```json
{
  "formulas": [{ "formula": "query1 / query2", "alias": "Error rate" }],
  "queries": [
    { "data_source": "metrics", "name": "query1",
      "query": "sum:trace.http.request.errors{env:prod,service:checkout}" },
    { "data_source": "metrics", "name": "query2",
      "query": "sum:trace.http.request.hits{env:prod,service:checkout}" }
  ]
}
```

**Correct (totals divided by totals):**

```json
{
  "formulas": [{ "formula": "query1 / query2", "alias": "Error rate" }],
  "queries": [
    { "data_source": "metrics", "name": "query1",
      "query": "sum:trace.http.request.errors{env:prod,service:checkout}.as_count()" },
    { "data_source": "metrics", "name": "query2",
      "query": "sum:trace.http.request.hits{env:prod,service:checkout}.as_count()" }
  ]
}
```

Two structural limits shape how far formulas can be pushed. Formulas cannot reference other formulas — *"Formulas are not lettered. Arithmetic cannot be done between formulas"* — so a ratio of two ratios has to be flattened into one expression over the underlying queries. And a formula may combine queries from different data sources, which is what makes cost-per-request or errors-per-deploy expressible at all; each query carries its own `name` and the formula refers to those names regardless of where the data came from.

The unique-count case does not obey this rule and cannot be repaired by modifiers. A ratio of two `cardinality` queries distorts with the rollup window because a subject recurring inside a window lands once in the denominator and repeatedly in the numerator — see `query-rollup-changes-the-number`.

Reference: [as_count() in monitor evaluations](https://docs.datadoghq.com/monitors/guide/as-count-in-monitor-evaluations/) · [Querying](https://docs.datadoghq.com/dashboards/querying/)
