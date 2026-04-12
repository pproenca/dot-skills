---
title: Track Coverage and Exposure Gini
impact: MEDIUM-HIGH
impactDescription: enables death-spiral detection
tags: obs, coverage, gini
---

## Track Coverage and Exposure Gini

Coverage — the percentage of active inventory recommended at least once in a rolling window — and the Gini coefficient of exposure — how unequally impressions are distributed across items — are the two health signals that catch winner-take-all pathologies before users notice. A falling coverage with a rising Gini is the fingerprint of a death spiral. Dashboard these two metrics alongside CTR and booking rate; alerts on them fire earlier than business metrics and give the team time to inject exploration before damage spreads.

**Incorrect (only CTR and booking rate tracked — death spiral invisible):**

```python
def publish_weekly_health() -> None:
    metrics.publish({
        "ctr": dashboard.fetch("ctr"),
        "booking_rate": dashboard.fetch("booking_rate"),
    })
```

**Correct (coverage and Gini published alongside business metrics):**

```python
def publish_weekly_health() -> None:
    metrics.publish({
        "ctr": dashboard.fetch("ctr"),
        "booking_rate": dashboard.fetch("booking_rate"),
        "catalog_coverage_7d": dashboard.fetch("percent_items_recommended", window_days=7),
        "catalog_coverage_30d": dashboard.fetch("percent_items_recommended", window_days=30),
        "exposure_gini_top_24": dashboard.fetch("gini_coefficient_top_n", n=24),
        "provider_gini_7d": dashboard.fetch("provider_exposure_gini", window_days=7),
    })
```

Reference: [Bias and Debias in Recommender System: A Survey (arXiv 2010.03240)](https://arxiv.org/pdf/2010.03240)
