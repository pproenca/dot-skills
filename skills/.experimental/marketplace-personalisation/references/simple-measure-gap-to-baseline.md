---
title: Measure the Gap to Baseline on Every Change
impact: HIGH
impactDescription: prevents accidental regression against popularity
tags: simple, baseline, regression
---

## Measure the Gap to Baseline on Every Change

When teams retire the baseline after the first ML win, they lose the reference point that would have caught a silent regression months later — a model that beat popularity at launch may drift below it after six recipe upgrades, training-data rewrites and schema changes. Keep the popularity baseline alive in a permanent minority bucket (1-5% of traffic) so every subsequent experiment can compare against it, not just against the current production model.

**Incorrect (baseline turned off after first ML launch, no regression guard):**

```python
experiments.set_traffic_allocation({
    "popularity_baseline": 0,
    "user_personalization_v2": 80,
    "new_rerank_model": 20,
})
```

**Correct (baseline retained as permanent minority bucket):**

```python
experiments.set_traffic_allocation({
    "popularity_baseline": 3,
    "user_personalization_v2": 77,
    "new_rerank_model": 20,
})
```

Reference: [Google — Rules of Machine Learning, Rule 27: Try to Quantify Observed Undesirable Behaviour](https://developers.google.com/machine-learning/guides/rules-of-ml)
