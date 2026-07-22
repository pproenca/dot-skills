---
title: Route the request to a monitor, SLO, or notebook when it is not a dashboard
tags: scope, notebooks, monitors, slo
---

## Route the request to a monitor, SLO, or notebook when it is not a dashboard

"Can you set something up so we know if checkout error rate spikes?" reads as a dashboard request and is not one — nobody watches a screen at 3am. A dashboard is a pull surface; wanting to be told is a monitor. Building the wrong artifact is worse than building nothing, because it looks like the need was met. Datadog names the failure mode for the exploratory case specifically: *"Save one-off explorations for Notebooks or Quick Graphs. When exploring an individual metric or graph, try Notebooks, which are unsaved by default, or Quick Graphs rather than creating a new dashboard that needs to be deleted."*

Match the signal in the request to the artifact:

```text
"tell me / alert us / let us know when X"     -> monitor
"are we meeting our target / how much budget"  -> SLO, then an slo widget on a dashboard
"why did X happen last Tuesday"                -> notebook (prose between graphs, shareable narrative)
"write up the incident / document the runbook" -> notebook (Postmortem or Runbook type tag)
"show me this one metric right now"            -> Quick Graph or Metrics Explorer, saved nowhere
recurring question, several viewers, live      -> dashboard
```

The notebook boundary is the one most often crossed. Notebooks support every widget type a dashboard does, plus rich text between them, so anything with a narrative — an investigation, a postmortem, a runbook whose steps need explaining — belongs there. Datadog describes them as *"collaborative rich text documents"* for *"an investigation or postmortem featuring live data"*. A dashboard has no place to put the sentence explaining what the graph means.

```json
{
  "tool": "create_datadog_notebook",
  "arguments": {
    "name": "Checkout latency regression 2026-07-19",
    "cells": [
      { "type": "markdown", "text": "p99 crossed 2s at 14:05 UTC, ~4 min after deploy 8f21c0e." },
      { "type": "timeseries", "query": "p99:trace.http.request{service:checkout,env:prod}" }
    ]
  }
}
```

When the answer is a monitor or an SLO, the dashboard is not cancelled — it becomes the place those live. An SLO widget beside its SLI detail is what Datadog names as the model team dashboard, and a monitor summary beats a hand-rolled threshold line (`widget-reuse-alerting-primitives`).

Reference: [Best practices for maintaining relevant dashboards](https://docs.datadoghq.com/dashboards/guide/maintain-relevant-dashboards/) · [Notebooks](https://docs.datadoghq.com/notebooks/) · [Alerting on what matters](https://www.datadoghq.com/blog/monitoring-101-alerting/)
