---
title: Slice Metrics by User Segment
impact: MEDIUM-HIGH
impactDescription: prevents aggregate-hides-regression failures
tags: obs, segmentation, metric-slicing
---

## Slice Metrics by User Segment

Aggregate metrics hide segment-level regressions with alarming regularity: a new model can lift booking rate 3% overall while collapsing it 15% for first-time users whose volume happens to be small. Slicing every primary metric by user segment (new vs repeat, cold vs warm, by region, by device, by referral source) surfaces those regressions early. Simpson's paradox — where an aggregate lift hides a segment loss — is routine in recommender A/B tests and only slicing catches it.

**Incorrect (only aggregate booking rate inspected — Simpson's paradox invisible):**

```python
def evaluate(experiment: Experiment) -> Decision:
    metrics = experiment.primary_metric()
    if metrics.treatment > metrics.control and metrics.p_value < 0.05:
        return Decision.SHIP
    return Decision.KILL
```

**Correct (segment breakdown is a ship-blocker if any segment regresses):**

```python
def evaluate(experiment: Experiment) -> Decision:
    overall = experiment.primary_metric()
    if overall.treatment <= overall.control or overall.p_value >= 0.05:
        return Decision.KILL

    segments = ["new_users", "repeat_users", "cold_cohort", "warm_cohort"]
    for segment in segments:
        sliced = experiment.primary_metric(segment=segment)
        if sliced.treatment < sliced.control * 0.98:
            return Decision.INVESTIGATE
    return Decision.SHIP
```

Reference: [Google — Rules of Machine Learning, Rule 28: Beware of Feedback Loops at Serving Time](https://developers.google.com/machine-learning/guides/rules-of-ml)
