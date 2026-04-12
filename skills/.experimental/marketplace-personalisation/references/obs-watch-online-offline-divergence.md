---
title: Watch for Online and Offline Metric Divergence
impact: MEDIUM-HIGH
impactDescription: prevents proxy-metric overfitting
tags: obs, offline-metrics, divergence
---

## Watch for Online and Offline Metric Divergence

Offline metrics (precision@k, recall@k, NDCG on held-out history) are a proxy, not the truth — the truth is the online A/B test. A new solution version with higher offline AUC but flat online CTR is overfitting the proxy, not learning real preference. Tracking the divergence over successive solution versions (Δ offline-metric vs Δ online-metric) catches when the team is optimising the wrong thing. A persistent divergence is the signal to rebuild the offline evaluation against a held-out time window that reflects real use.

**Incorrect (offline metric is the only gate for a model promotion):**

```python
def promote_if_better(candidate: SolutionVersion, current: SolutionVersion) -> None:
    if candidate.offline_metrics.auc > current.offline_metrics.auc:
        deploy_campaign(candidate)
```

**Correct (online A/B is the final gate, divergence dashboarded):**

```python
def promote_if_better(candidate: SolutionVersion, current: SolutionVersion) -> None:
    if candidate.offline_metrics.auc <= current.offline_metrics.auc:
        return

    experiment = ab_test(
        control=current,
        treatment=candidate,
        primary_metric="booking_completed_per_session",
    )
    result = experiment.wait_for_significance()

    dashboard.record_divergence(
        offline_delta=candidate.offline_metrics.auc - current.offline_metrics.auc,
        online_delta=result.relative_lift,
        version=candidate.arn,
    )
    if result.relative_lift > 0.0 and result.p_value < 0.05:
        deploy_campaign(candidate)
```

Reference: [Google — Rules of Machine Learning, Rule 36: Avoid Feedback Loops with Positional Features](https://developers.google.com/machine-learning/guides/rules-of-ml)
