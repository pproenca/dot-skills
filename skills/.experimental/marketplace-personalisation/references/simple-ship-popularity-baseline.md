---
title: Ship a Popularity Baseline Before ML
impact: HIGH
impactDescription: reduces premature ML spend by 100%
tags: simple, baseline, popularity
---

## Ship a Popularity Baseline Before ML

Every recommender project should begin with a non-ML popularity baseline, served end-to-end through the real inference path, with real metrics. Most teams discover their initial ML effort does not beat the baseline on online metrics — and that discovery costs nothing if the baseline was a weekend of work and everything if the baseline was never built. The baseline is also the reference point that every future model must justify itself against.

**Incorrect (jump straight to USER_PERSONALIZATION_v2 with no baseline):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    response = personalize_runtime.get_recommendations(
        campaignArn=CAMPAIGN_ARN,
        userId=seeker.id,
        numResults=24,
    )
    return hydrate_listings(response["itemList"])
```

**Correct (popularity baseline as variant A of the first A/B test):**

```python
def homefeed(seeker: Seeker, variant: str) -> list[Listing]:
    if variant == "popularity_baseline":
        return catalog.top_by_completed_bookings(
            region=seeker.last_region,
            window_days=30,
            limit=24,
        )
    response = personalize_runtime.get_recommendations(
        campaignArn=CAMPAIGN_ARN,
        userId=seeker.id,
        numResults=24,
    )
    return hydrate_listings(response["itemList"])
```

Reference: [Google — Rules of Machine Learning, Rule 1: Do Not Be Afraid to Launch a Product Without Machine Learning](https://developers.google.com/machine-learning/guides/rules-of-ml)
