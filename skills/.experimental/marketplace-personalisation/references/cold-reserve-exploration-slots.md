---
title: Reserve Exploration Slots for New Inventory
impact: HIGH
impactDescription: enables new-listing discovery
tags: cold, exploration, new-items
---

## Reserve Exploration Slots for New Inventory

A newly created listing has no interaction history, so a pure-relevance ranker never surfaces it, so it never accumulates interactions, so the ranker keeps ignoring it. Reserving a fixed fraction of slots (or injecting a new-listing promotion filter) gives new inventory a guaranteed chance to be discovered. Personalize supports this directly via promotion filters on recommendation requests — the promotion filter selects items by `CREATION_TIMESTAMP` and reserves a percentage of the output for matches.

**Incorrect (straight ranker output, new inventory never surfaces):**

```python
response = personalize_runtime.get_recommendations(
    campaignArn=CAMPAIGN_ARN,
    userId=seeker.id,
    numResults=24,
)
```

**Correct (20% of slots reserved for listings created in the last 14 days):**

```python
response = personalize_runtime.get_recommendations(
    campaignArn=CAMPAIGN_ARN,
    userId=seeker.id,
    numResults=24,
    promotions=[{
        "name": "fresh-listings",
        "percentPromotedItems": 20,
        "filterArn": FILTER_ARN_NEW_LISTINGS,
        "filterValues": {
            "MIN_CREATION_TIMESTAMP": str(int((datetime.utcnow() - timedelta(days=14)).timestamp())),
        },
    }],
)
```

Reference: [AWS Personalize — Recommend and Dynamically Filter Based on User Context](https://aws.amazon.com/blogs/machine-learning/recommend-and-dynamically-filter-items-based-on-user-context-in-amazon-personalize/)
