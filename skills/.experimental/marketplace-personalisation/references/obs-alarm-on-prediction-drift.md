---
title: Alarm on Prediction Distribution Drift
impact: MEDIUM
impactDescription: prevents silent model staleness
tags: obs, drift, monitoring
---

## Alarm on Prediction Distribution Drift

A deployed model's prediction distribution (score histogram, category mix of top-24, average position of cold items) is stable in normal operation. When it shifts — a seasonal trend, a schema import glitch, a silent dataset corruption, a deployment regression — the business metrics take days to reflect the damage but the prediction distribution shifts within hours. Monitoring KL-divergence between today's distribution and a rolling reference distribution catches these failures early and is often the first indicator that something deeper is wrong.

**Incorrect (only business metrics are monitored — prediction drift invisible):**

```python
def daily_health_check() -> None:
    metrics.check("booking_rate", threshold=-0.05)
    metrics.check("ctr", threshold=-0.05)
```

**Correct (prediction distribution KL-divergence alarm alongside business metrics):**

```python
def daily_health_check() -> None:
    metrics.check("booking_rate", threshold=-0.05)
    metrics.check("ctr", threshold=-0.05)

    today_dist = predictions.distribution_histogram(day=date.today())
    baseline_dist = predictions.rolling_reference_distribution(window_days=14)
    divergence = kl_divergence(today_dist, baseline_dist)

    if divergence > 0.15:
        pager.alert(
            f"Prediction distribution drift: KL={divergence:.3f}",
            runbook="playbooks/improving.md#prediction-drift",
        )
```

Reference: [Google — Rules of Machine Learning, Rule 38: Do Not Waste Time on New Features if Unaligned Objectives Become the Issue](https://developers.google.com/machine-learning/guides/rules-of-ml)
