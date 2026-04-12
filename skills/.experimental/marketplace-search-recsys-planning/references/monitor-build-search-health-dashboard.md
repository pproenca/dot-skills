---
title: Build a Search Health Dashboard with Threshold Lines
impact: MEDIUM
impactDescription: enables at-a-glance quality monitoring
tags: monitor, dashboard, thresholds
---

## Build a Search Health Dashboard with Threshold Lines

A search system needs a single-pane-of-glass dashboard that shows the current state of every upstream and downstream metric with an explicit threshold line indicating the decision boundary — below the line means the team acts, above it means the system is healthy. Raw time series without threshold lines force the viewer to remember whether "12% zero results" is good or bad; a dashed horizontal line at 10% with colour banding makes the interpretation instant. The dashboard is not a metric showcase — it is a decision-making artefact.

**Incorrect (raw metric dashboard with no thresholds, interpretation unclear):**

```python
dashboard.add_panel(title="Zero Result Rate", metric="search.zero_result_rate")
dashboard.add_panel(title="NDCG@10", metric="search.ndcg_at_10")
dashboard.add_panel(title="Reformulation Rate", metric="search.reformulation_rate")
```

**Correct (every panel has a threshold line and colour-banded state):**

```python
dashboard.add_panel(
    title="Zero Result Rate",
    metric="search.zero_result_rate",
    threshold=Threshold(warning=0.08, critical=0.12, direction="below_is_better"),
    colour_bands=[(0, 0.08, "green"), (0.08, 0.12, "yellow"), (0.12, 1.0, "red")],
)
dashboard.add_panel(
    title="NDCG@10 (golden set v3.2)",
    metric="search.ndcg_at_10_golden_v3_2",
    threshold=Threshold(warning=0.68, critical=0.65, direction="above_is_better"),
    baseline_line=0.70,
)
dashboard.add_panel(
    title="Reformulation Rate (60s)",
    metric="search.reformulation_rate_60s",
    threshold=Threshold(warning=0.18, critical=0.25, direction="below_is_better"),
)
```

Reference: [Google — Rules of Machine Learning, Rule 8: Know the Freshness Requirements of Your System](https://developers.google.com/machine-learning/guides/rules-of-ml)
