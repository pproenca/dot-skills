---
title: Include Context Fields in Training and Inference
impact: HIGH
impactDescription: prevents training-serving feature divergence
tags: schema, context, inference
---

## Include Context Fields in Training and Inference

Context fields (surface, device, hour-of-day, weather) are only useful if they exist at both train time and serve time. A field that was present during training but omitted from the GetRecommendations call is silently defaulted by Personalize, so the model applies its learned weights to a missing feature and recommendations drift. The rule is brutal but simple: every context field in the schema must be populated in every inference call.

**Incorrect (context fields in schema, missing from inference):**

```python
# Interactions schema declares SURFACE and DEVICE as categorical fields...
response = personalize_runtime.get_recommendations(
    campaignArn=CAMPAIGN_ARN,
    userId=seeker_id,
    numResults=24,
)
```

**Correct (every declared context field is passed at inference):**

```python
response = personalize_runtime.get_recommendations(
    campaignArn=CAMPAIGN_ARN,
    userId=seeker_id,
    numResults=24,
    context={
        "SURFACE": request.surface,
        "DEVICE": request.device,
        "HOUR_OF_DAY": str(datetime.utcnow().hour),
    },
)
```

Reference: [AWS Personalize — Recommend and Dynamically Filter Based on User Context](https://aws.amazon.com/blogs/machine-learning/recommend-and-dynamically-filter-items-based-on-user-context-in-amazon-personalize/)
