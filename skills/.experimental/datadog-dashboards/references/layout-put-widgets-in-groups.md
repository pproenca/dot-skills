---
title: Organise every widget into a group, starting with About and Overview
tags: layout, groups, structure, readability
---

## Organise every widget into a group, starting with About and Overview

Widgets emitted in the order they were thought of, sitting directly on the dashboard background, produce a wall that has to be read linearly to find anything. Datadog's standard for the dashboards it ships with its own integrations is explicit that this is not acceptable: *"All widgets are placed within a group based on thematic organization, rather than directly on the background."* Grouping is the difference between a board that can be scanned during an incident and one that has to be searched.

The prescribed opening is fixed, and it front-loads the answer:

```text
About     - what this dashboard is for, links, ownership (content, not full width)
Overview  - service checks, key metrics, monitor summary — the most important data, at the top
...       - domain groups, macro to micro, upstream to downstream
Logs      - log volume by status + an error-filtered stream, at the very end
```

Streams belong last because they trap scrolling — a reader dragging past a log stream scrolls the stream instead of the page. Within the middle, Datadog's ordering rules are to *"progress from macro to micro levels"* and to *"arrange from upstream to downstream"*, grouping metrics that reveal similar actionable insights rather than metrics that happen to share a source.

```json
{
  "definition": {
    "type": "group",
    "title": "Overview",
    "layout_type": "ordered",
    "background_color": "vivid_blue",
    "show_title": true,
    "widgets": [
      { "definition": { "type": "slo", "slo_id": "b0f2a71c9d3e4a5f8c1b2d3e4f5a6b7c",
                        "view_type": "detail", "time_windows": ["30d"] } },
      { "definition": { "type": "manage_status", "query": "tag:(service:checkout env:prod)",
                        "summary_type": "monitors", "display_format": "countsAndList" } }
    ]
  }
}
```

The About group is where the dashboard explains itself, using a `note` widget with Markdown. That is the cheapest durable improvement available: a board whose purpose is written on it survives its author leaving, and Datadog's hygiene guidance treats an undocumented dashboard as a candidate for deletion. Widget-level descriptions do the same job one level down — *"what it represents, how to interpret it, or what action to take"* — and matter most on the panels whose correct reading is not obvious.

Group colour is a grouping signal rather than decoration: coordinating the header, the note, and the graphs within a group is part of the same standard.

Widths matter to grouping because an undersized widget cannot be read regardless of where it sits. On the 12-column grid, timeseries widgets want at least 4 columns and stream widgets at least 6 — which is the second reason streams go last, since a half-width block mid-page fragments everything around it.

Reference: [Datadog integration dashboard guidelines](https://datadoghq.dev/integrations-core/guidelines/dashboards/) · [Best practices for maintaining relevant dashboards](https://docs.datadoghq.com/dashboards/guide/maintain-relevant-dashboards/)
