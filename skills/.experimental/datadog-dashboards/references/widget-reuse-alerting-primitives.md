---
title: Embed the SLO and monitor that already exist instead of redrawing them
tags: widget, slo, monitors, alerting
---

## Embed the SLO and monitor that already exist instead of redrawing them

Asked to show whether a service is healthy, the default is to graph the metric and draw a threshold line at whatever number sounds right. That reinvents a definition of "healthy" that the team has usually already agreed, written down, and attached alerting to — and the reinvention immediately diverges from it, so the dashboard says fine while the monitor pages. The threshold on the graph is a guess; the monitor's threshold is the commitment.

Look for both before drawing anything. `search_datadog_slos` and `search_datadog_monitors` answer in one call each, and the results become widgets rather than reference material. Datadog names the SLO pairing as the model team dashboard: *"SLO and SLI details make for an excellent team dashboard."*

```json
{
  "definition": {
    "type": "slo",
    "title": "Checkout availability",
    "view_type": "detail",
    "slo_id": "b0f2a71c9d3e4a5f8c1b2d3e4f5a6b7c",
    "time_windows": ["7d", "30d"],
    "show_error_budget": true,
    "view_mode": "both"
  }
}
```

An SLO widget carries error budget, which is the number an on-call engineer actually needs — "we have burned 60% of the month's budget" drives a decision in a way that "latency is 240ms" does not. For monitors, `manage_status` (the Monitor Summary widget, whose JSON type does not match its UI name) gives current alert state across a scope in one tile, and `alert_graph` embeds a specific monitor's evaluation so the graph and the alert cannot disagree.

```json
{
  "definition": {
    "type": "manage_status",
    "title": "Checkout monitors",
    "query": "tag:(service:checkout env:prod)",
    "summary_type": "monitors",
    "display_format": "countsAndList",
    "color_preference": "background",
    "sort": "status,asc"
  }
}
```

When no SLO or monitor exists, drawing a threshold is still the wrong first move — say so, and offer to create the monitor. A horizontal marker is worth adding to a graph even alongside these, because it removes the mental mapping between a line and a number; Datadog's Powerpack guidance puts it directly: *"Horizontal markers reduce the visual mapping a viewer has to do by clearly defining acceptable thresholds on a graph."* Markers combine a severity and a line style, as in `error dashed` or `warning solid`.

Reference: [SLO widget](https://docs.datadoghq.com/dashboards/widgets/slo/) · [Monitor Summary widget](https://docs.datadoghq.com/dashboards/widgets/monitor_summary/) · [Powerpacks best practices](https://docs.datadoghq.com/dashboards/guide/powerpacks-best-practices/)
