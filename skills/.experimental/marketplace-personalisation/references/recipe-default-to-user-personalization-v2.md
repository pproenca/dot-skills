---
title: Default to USER_PERSONALIZATION_v2 for Discovery
impact: MEDIUM-HIGH
impactDescription: enables 5 million item catalog with lower latency
tags: recipe, user-personalization, discovery
---

## Default to USER_PERSONALIZATION_v2 for Discovery

For discovery surfaces (homefeed, category landing, personalised shelves), USER_PERSONALIZATION_v2 is the default choice: it supports up to five million items, trains faster than v1, produces lower-latency recommendations, uses both item metadata and interactions for cold-start, and supports contextual features at inference. Pick a different recipe only when there is a specific reason — similar-item recommendations on a detail page (SIMS), re-ranking a user-provided list (PERSONALIZED_RANKING), or a baseline fallback.

**Incorrect (using SIMS for homepage, ignores user history):**

```python
personalize.create_solution(
    name="homefeed-sims",
    datasetGroupArn=DATASET_GROUP_ARN,
    recipeArn="arn:aws:personalize:::recipe/aws-sims",
)
```

**Correct (USER_PERSONALIZATION_v2 for discovery surfaces):**

```python
personalize.create_solution(
    name="homefeed-user-personalization-v2",
    datasetGroupArn=DATASET_GROUP_ARN,
    recipeArn="arn:aws:personalize:::recipe/aws-user-personalization-v2",
    eventsConfig={
        "eventParametersList": [
            {"eventType": "booking_completed", "weight": 10.0},
            {"eventType": "click", "weight": 1.0},
        ],
    },
)
```

Reference: [AWS Personalize — User-Personalization-v2 Recipe](https://docs.aws.amazon.com/personalize/latest/dg/native-recipe-user-personalization-v2.html)
