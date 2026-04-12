---
title: Budget Each Model with a Ship or Kill Criterion
impact: HIGH
impactDescription: prevents indefinite incubation of dead experiments
tags: simple, experimentation, budgeting
---

## Budget Each Model with a Ship or Kill Criterion

An ML experiment without a predefined ship/kill criterion will drift — it will always be "nearly there", "needs one more week", "looking promising on offline metrics". Declaring the success criterion before running the experiment (e.g., "ship if online booking lift ≥ 2% with p < 0.05; kill otherwise") removes hindsight bias, stops zombie projects from consuming training budget, and keeps the team focused on the next candidate improvement. Every solution version should have an entry in a decisions log that records its criterion and outcome.

**Incorrect (open-ended experiment with no exit criterion):**

```python
experiments.create(
    name="user-personalization-v2-bptt-40",
    variant="test",
    traffic_pct=10,
    notes="Testing longer sequence length. Let us see how it performs.",
)
```

**Correct (predefined criterion stored alongside the experiment):**

```python
experiments.create(
    name="user-personalization-v2-bptt-40",
    variant="test",
    traffic_pct=10,
    ship_criterion=ShipCriterion(
        primary_metric="booking_completed_per_session",
        min_relative_lift=0.02,
        max_p_value=0.05,
        required_sample_size=40_000,
        max_duration_days=21,
    ),
    kill_criterion=KillCriterion(
        regression_threshold=-0.01,
        triggers=["gini_exposure_top_quartile", "coverage_collapse"],
    ),
)
```

Reference: [Google — Rules of Machine Learning, Rule 12: Do Not Overthink Which Objective to Optimise](https://developers.google.com/machine-learning/guides/rules-of-ml)
