---
title: Retain a Feature-Free Baseline Permanently
impact: MEDIUM
impactDescription: prevents silent ML-vs-baseline gap collapse
tags: prove, baseline, regression, popularity
---

## Retain a Feature-Free Baseline Permanently

A popularity baseline (top-N listings by completed bookings in the region over the last 30 days) uses zero learned features and should remain a small permanent traffic slice even after the ML model has been winning for a year. Its purpose is not to beat the ML model — it will not — but to act as a drift anchor: if the gap between the ML model and the baseline shrinks below a threshold, something has gone wrong (drift, coverage drop, broken feature). The baseline is the canary, and retaining it is the cheapest feature-portfolio insurance you can buy.

**Incorrect (baseline retired as soon as ML proves itself):**

```python
# experiment "ml_v1 vs popularity" finished with +4% lift, popularity variant deleted
# 6 months later, a feature drop silently regresses the ML model to baseline-level performance
# nobody notices because there is no comparison point
```

**Correct (permanent 2% baseline slice with an alarm on the gap):**

```python
BASELINE_TRAFFIC_PCT = 0.02
GAP_ALARM_THRESHOLD_PCT = 1.5  # if ML only beats baseline by <1.5%, page the team

def route(sitter_id: str) -> Model:
    bucket = hash(sitter_id) % 100
    if bucket < int(BASELINE_TRAFFIC_PCT * 100):
        return popularity_baseline_model()
    return current_ml_model()

def daily_gap_check() -> None:
    ml_rate = online_metrics.booking_rate(model="ml_v14", window="24h")
    base_rate = online_metrics.booking_rate(model="popularity_baseline", window="24h")
    gap_pct = 100 * (ml_rate - base_rate) / base_rate
    if gap_pct < GAP_ALARM_THRESHOLD_PCT:
        alert(f"ML-vs-baseline gap collapsed to {gap_pct:.1f}%", severity="page")
```

Reference: [Google — Rules of Machine Learning, Rule #1: Don't be afraid to launch a product without machine learning](https://developers.google.com/machine-learning/guides/rules-of-ml)
