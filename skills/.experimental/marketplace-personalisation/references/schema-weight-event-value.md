---
title: Use EVENT_VALUE to Weight Outcomes over Clicks
impact: HIGH
impactDescription: enables outcome-weighted training
tags: schema, event-value, weights
---

## Use EVENT_VALUE to Weight Outcomes over Clicks

Without EVENT_VALUE, a click and a completed booking count equally during training. That means the model learns that browsing behaviour is the goal, not the transaction that produced revenue and mutual satisfaction. Setting a per-event-type weight (and using EVENT_VALUE where the magnitude matters, like nights stayed or total price) aligns the model's optimisation target with the business outcome.

**Incorrect (no event-type weighting, click treated as equal to booking):**

```python
solution_config = {
    "name": "homefeed-v1",
    "datasetGroupArn": DATASET_GROUP_ARN,
    "recipeArn": "arn:aws:personalize:::recipe/aws-user-personalization-v2",
}
personalize.create_solution(**solution_config)
```

**Correct (event configuration weights booking_completed 10× click):**

```python
solution_config = {
    "name": "homefeed-v1",
    "datasetGroupArn": DATASET_GROUP_ARN,
    "recipeArn": "arn:aws:personalize:::recipe/aws-user-personalization-v2",
    "eventsConfig": {
        "eventParametersList": [
            {"eventType": "booking_completed", "weight": 10.0, "eventValueThreshold": "1"},
            {"eventType": "booking_request", "weight": 4.0},
            {"eventType": "click", "weight": 1.0},
            {"eventType": "dismiss", "weight": 0.1},
        ],
    },
}
personalize.create_solution(**solution_config)
```

Reference: [AWS Personalize — Optimizing a Solution with Events Configuration](https://docs.aws.amazon.com/personalize/latest/dg/optimizing-solution-events-config.html)
