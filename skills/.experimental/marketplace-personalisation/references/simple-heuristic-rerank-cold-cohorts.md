---
title: Use Heuristic Re-ranking for Cold Cohorts
impact: HIGH
impactDescription: enables useful ranking with zero interactions
tags: simple, heuristics, cold-start
---

## Use Heuristic Re-ranking for Cold Cohorts

For a seeker or listing with no interaction history, the ML model has nothing to learn from — it is reduced to global popularity plus random noise. A simple heuristic that combines stable, interpretable signals (trust score, recency, geographic proximity, completion rate) produces a useful ranking without waiting for data to accumulate. The heuristic then becomes the long-term fallback for cold cohorts even after the ML model is deployed for warm cohorts.

**Incorrect (ML model as the only path, cold users get noise):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    response = personalize_runtime.get_recommendations(
        campaignArn=CAMPAIGN_ARN,
        userId=seeker.id,
        numResults=24,
    )
    return hydrate_listings(response["itemList"])
```

**Correct (heuristic fallback for cold cohorts, ML for warm):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    if seeker.lifetime_events < 5:
        return heuristic_rank(
            retrieve_feasible(seeker),
            scoring=lambda listing: (
                0.5 * listing.trust_score +
                0.3 * recency_decay(listing.last_active_at) +
                0.2 * proximity(listing.region, seeker.last_region)
            ),
        )[:24]
    response = personalize_runtime.get_recommendations(
        campaignArn=CAMPAIGN_ARN,
        userId=seeker.id,
        numResults=24,
    )
    return hydrate_listings(response["itemList"])
```

Reference: [Google — Rules of Machine Learning, Rule 4: Keep the First Model Simple](https://developers.google.com/machine-learning/guides/rules-of-ml)
