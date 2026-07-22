---
title: Split the wallboard from the triage board rather than serving both
tags: layout, tv-mode, refresh, wallboards
---

## Split the wallboard from the triage board rather than serving both

Asked for a dashboard the team can leave on a screen *and* use during incidents, the reflex is to build one board that does both. The two have contradictory contracts, and TV mode makes the contradiction mechanical rather than aesthetic: it works by *"ensuring that all widgets are visible without requiring scrolling"*, which it achieves by scaling the whole board down to fit. Every widget added shrinks every other widget. A wallboard therefore degrades continuously as it grows, with no threshold that announces itself — it is legible at eight widgets and unreadable at twenty, and nothing in between flags the crossing. A triage board has the opposite contract: it is expected to scroll, and cutting it to fit a screen would strip the detail it exists to carry.

Decide which is being built and let it bound the widget count up front. Datadog publishes no maximum; for a wallboard the operative limit is legibility across a room, which lands around six to twelve widgets.

Refresh rate follows the time frame and is not a promise to make independently. It degrades sharply on long windows — 10 seconds at ten minutes or less, 1 minute at three to four hours, and **1 hour at a week and beyond** — so a "live" wallboard showing a quarter updates hourly. Publicly shared dashboards are the exception, refreshing every 30 seconds regardless. Pick a default time frame the wallboard's purpose can live with:

```json
{
  "title": "Checkout - NOC Wallboard",
  "layout_type": "ordered",
  "reflow_type": "auto",
  "default_timeframe": { "type": "live", "value": 4, "unit": "hour" }
}
```

Check both 1280px and 2560px before shipping either kind, since an ordered layout reflows between them and a grouping that reads well at one width can interleave at the other. For a wall display where placement has to be exact, a free-layout screenboard beats TV mode over an ordered board — TV mode scaling a disproportionate aspect ratio leaves white edges and shrinks everything to fit the worst dimension. Enable it while already full-screen on the target display, since it fits to the window it is invoked from.

Reference: [TV mode](https://docs.datadoghq.com/dashboards/guide/tv_mode/) · [Dashboards](https://docs.datadoghq.com/dashboards/) · [Datadog integration dashboard guidelines](https://datadoghq.dev/integrations-core/guidelines/dashboards/)
