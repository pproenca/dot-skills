---
title: Find the Bottleneck Before Optimizing
impact: HIGH
impactDescription: prevents work on non-bottleneck stages
tags: simple, bottleneck, theory-of-constraints
---

## Find the Bottleneck Before Optimizing

Goldratt's Theory of Constraints observes that the throughput of a system is governed by a single bottleneck — work on anything else produces no end-to-end improvement. In a recommender, the bottleneck is rarely the algorithm; it is most often event-tracking coverage, dataset freshness, inventory coverage, or trust-signal quality. Running a structured diagnostic (see `references/playbooks/improving.md`) before any optimisation work prevents spending a quarter fine-tuning hyperparameters when the real problem is that 40% of bookings never emit a `booking_completed` event.

**Incorrect (jumping to hyperparameter tuning without diagnosis):**

```python
hpo_config = {
    "solutionConfig": {
        "hpoConfig": {
            "algorithmHyperParameterRanges": {
                "integerHyperParameterRanges": [
                    {"name": "bptt", "minValue": 20, "maxValue": 40},
                    {"name": "recency_mask", "minValue": 0, "maxValue": 1},
                ],
            },
        },
    },
    "performHPO": True,
}
personalize.create_solution(**hpo_config)
```

**Correct (diagnostic checklist first, then targeted fix):**

```python
def diagnose_recommender_health() -> BottleneckReport:
    return BottleneckReport(
        tracking_coverage=audit.percent_bookings_with_completion_event(),
        item_freshness_p99=audit.item_metadata_staleness_seconds(percentile=99),
        catalog_coverage=audit.percent_items_ever_recommended(window_days=7),
        gap_to_popularity_baseline=ab_test.relative_lift_over_popularity(),
        offline_online_drift=drift.online_ctr_minus_offline_auc(),
    )
```

Reference: [Google — Rules of Machine Learning, Rule 16: Plan to Launch and Iterate](https://developers.google.com/machine-learning/guides/rules-of-ml)
