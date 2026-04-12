---
title: Optimize for Completed Outcome, Not Click
impact: HIGH
impactDescription: prevents clickbait reward in feedback loop
tags: loop, outcome-optimization, event-weights
---

## Optimize for Completed Outcome, Not Click

What you reward is what you will get. If the training signal is dominated by clicks, the next model generation will rank for clickbait — eye-catching photos, aggressive pricing, sensational titles — even when those listings underperform on bookings. The feedback loop reinforces the proxy, not the goal. Setting event weights so that `booking_completed` dominates `click` at training time realigns the loop with the business outcome and compounds every retraining cycle.

**Incorrect (implicit equal weight — the loop reinforces the click proxy):**

```python
solution_config = {
    "name": "homefeed-v2",
    "datasetGroupArn": DATASET_GROUP_ARN,
    "recipeArn": "arn:aws:personalize:::recipe/aws-user-personalization-v2",
}
personalize.create_solution(**solution_config)
```

**Correct (explicit outcome-weighted training reinforces completion):**

```python
solution_config = {
    "name": "homefeed-v2",
    "datasetGroupArn": DATASET_GROUP_ARN,
    "recipeArn": "arn:aws:personalize:::recipe/aws-user-personalization-v2",
    "eventsConfig": {
        "eventParametersList": [
            {"eventType": "booking_completed", "weight": 12.0},
            {"eventType": "booking_request", "weight": 5.0},
            {"eventType": "click", "weight": 1.0},
            {"eventType": "dismiss", "weight": 0.1},
        ],
    },
}
personalize.create_solution(**solution_config)
```

Reference: [AWS Personalize — Optimizing a Solution with Events Configuration](https://docs.aws.amazon.com/personalize/latest/dg/optimizing-solution-events-config.html)
