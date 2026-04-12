---
title: Tag Cold-Start Recommendations for Separate Measurement
impact: HIGH
impactDescription: enables warm-vs-cold cohort comparison
tags: cold, instrumentation, metric-slicing
---

## Tag Cold-Start Recommendations for Separate Measurement

Aggregate CTR and booking-rate metrics hide a catastrophic truth: warm cohorts can be lifting while cold cohorts collapse, and the blended number looks flat. Tagging every cold-start response with an explicit `cold_start=true` property — and emitting the tag into every impression event — lets you slice every online metric by warmth and catch a cold-cohort regression before it drags down the aggregate. The tag is also what lets you A/B different cold-start strategies against each other.

**Incorrect (no warmth tag — cold and warm cohorts are indistinguishable in metrics):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    if seeker.lifetime_events < 5:
        return best_of_segment_popularity(seeker)
    response = personalize_runtime.get_recommendations(
        campaignArn=CAMPAIGN_ARN,
        userId=seeker.id,
        numResults=24,
    )
    return hydrate_listings(response["itemList"])
```

**Correct (warmth tag propagated into every downstream event):**

```python
def homefeed(seeker: Seeker, request_id: str) -> list[Listing]:
    if seeker.lifetime_events < 5:
        listings = best_of_segment_popularity(seeker)
        log_exposure(request_id, listings, cold_start=True, policy="segment_popularity")
        return listings

    response = personalize_runtime.get_recommendations(
        campaignArn=CAMPAIGN_ARN,
        userId=seeker.id,
        numResults=24,
    )
    listings = hydrate_listings(response["itemList"])
    log_exposure(request_id, listings, cold_start=False, policy="personalize_v2")
    return listings
```

Reference: [Airbnb — Machine Learning-Powered Search Ranking of Airbnb Experiences](https://medium.com/airbnb-engineering/machine-learning-powered-search-ranking-of-airbnb-experiences-110b4b1a0789)
