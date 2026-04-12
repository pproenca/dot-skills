---
title: Detect Popularity Death Spirals via Top-N Gini
impact: HIGH
impactDescription: prevents silent concentration collapse
tags: loop, gini, concentration
---

## Detect Popularity Death Spirals via Top-N Gini

A popularity death spiral is silent: the model ranks popular items higher, they get more impressions, more clicks, rise in the training data, and the next generation ranks them even higher — until the long tail is invisible and coverage collapses. Tracking the Gini coefficient of top-N exposure as a health signal catches this before it shows up in booking rates. A monotonically rising Gini over weeks is the death-spiral fingerprint — alert on it and inject exploration immediately.

**Incorrect (no concentration metric, collapse goes unnoticed):**

```python
def weekly_recommender_health_check() -> None:
    metrics = dashboard.fetch(["ctr", "booking_rate", "session_length"])
    alert_on_regression(metrics)
```

**Correct (exposure Gini tracked weekly, alerts on monotonic rise):**

```python
def weekly_recommender_health_check() -> None:
    metrics = dashboard.fetch(["ctr", "booking_rate", "session_length"])
    alert_on_regression(metrics)

    gini_series = dashboard.fetch_series("exposure_gini_top_24", weeks=6)
    if is_monotonically_increasing(gini_series) and gini_series[-1] > 0.65:
        pager.alert(
            "Exposure Gini rising for 6 consecutive weeks — likely death spiral",
            runbook="playbooks/improving.md#death-spiral",
        )
```

Reference: [Bias and Debias in Recommender System: A Survey (arXiv 2010.03240)](https://arxiv.org/pdf/2010.03240)
