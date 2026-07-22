---
title: Keep heatmap and distribution apart — one axis is time, the other is quantity
tags: widget, heatmap, distribution, histograms
---

## Keep heatmap and distribution apart — one axis is time, the other is quantity

Both render density, both are the answer to "show me the spread rather than the average", and the names are close enough that they get used interchangeably. They answer different questions, and Datadog draws the line in one sentence: *"Unlike the heatmap, a distribution graph's x-axis is quantity rather than time."*

That single difference decides which one a question wants. A **heatmap** keeps time on the x-axis and shows how the shape of the spread evolved — whether latency developed a slow tail during the incident, whether a second cluster of hosts appeared at 3am. A **distribution** collapses time entirely and shows one static shape across the selected window — what the latency histogram looks like right now, where the mass sits, whether it is bimodal. Asking "when did it get worse" of a distribution is unanswerable; asking "what is the shape" of a heatmap means reading it column by column.

```json
{
  "type": "distribution",
  "title": "Checkout request latency spread",
  "requests": [{
    "query": { "data_source": "metrics",
               "name": "query1",
               "query": "histogram:trace.http.request{$env,$service}" },
    "request_type": "histogram"
  }]
}
```

The space aggregator is `histogram:`, not `avg:` — with `request_type: histogram` the schema requires it, since the widget needs the point distribution rather than a collapsed average. Writing the familiar `avg:` here is the most common reason a distribution widget renders nothing.

Two further constraints on `distribution` shape the design around it. It plots a **single** query — additional queries are disregarded, so a two-service comparison needs two widgets rather than two requests. And Datadog notes that outlier detection cannot be performed on this visualization, so an anomaly-hunting panel belongs on a timeseries. Distribution also offers a `percentile` display type for APM latency markers that the heatmap does not.

`heatmap` needs its input to be a distribution-shaped metric (`request_type: histogram` for point-value distribution metrics and OTel histograms), or an explicitly aggregated grouped query — without a `sum by` / `avg by` selection there is nothing to spread across and the widget renders one flat band.

The related pair worth keeping straight for the same reason: `treemap` and `sunburst` both show nested proportions, and the only difference is the rendering — *"the pie chart displays proportions in radial slices, and the treemap displays nested rectangles."* Choose on label legibility, since long tag names fit rectangles and not slices.

Reference: [Distribution widget](https://docs.datadoghq.com/dashboards/widgets/distribution/) · [Heatmap widget](https://docs.datadoghq.com/dashboards/widgets/heatmap/) · [Pie Chart widget](https://docs.datadoghq.com/dashboards/widgets/pie_chart/)
