---
title: Tie Every Feature to a Specific Solution and Metric
impact: CRITICAL
impactDescription: prevents orphan features that cost maintenance without lift
tags: firstp, solution, metric, accountability
---

## Tie Every Feature to a Specific Solution and Metric

Every feature added to the store must name (a) which solution it feeds — item-to-item similarity (i2i), user-to-item affinity (u2i), or user-to-user mutual fit (u2u) — and (b) which primary metric it is hypothesised to improve (completed-booking rate, mutual-rating ≥4, request-to-acceptance rate). Features without a named solution and metric tend to be retained after the model that used them has been deleted, accumulating storage and drift risk with no owner. The solution tag is the contract that lets feature quality owners know whom to notify when a feature's coverage drops.

**Incorrect (feature is added to a shared table with no downstream contract):**

```sql
ALTER TABLE listing_features ADD COLUMN aesthetic_score FLOAT;
-- who uses this? what metric does it move? if CLIP is swapped, does anyone care?
```

**Correct (feature is registered against a solution + metric + owner):**

```python
feature_registry.register(
    name="listing_aesthetic_score",
    feature_group="listing_vision",
    solutions=["i2i_similar_homes", "u2i_homefeed_ranker"],
    hypothesis="Aesthetic score correlates with sitter accept probability",
    primary_metric="completed_booking_rate_per_impression",
    owner="ml-marketplace@trustedhousesitters.com",
    dtype="float32",
    coverage_sla=0.85,
)
# registration fails if owner/metric/solution are empty; a feature without a contract does not reach production.
```

Reference: [Google — Rules of Machine Learning, Rule #22: Clean up features you are no longer using](https://developers.google.com/machine-learning/guides/rules-of-ml)
