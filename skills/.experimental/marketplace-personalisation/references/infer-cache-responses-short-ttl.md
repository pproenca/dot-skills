---
title: Cache Responses by User Context with a Short TTL
impact: MEDIUM
impactDescription: reduces duplicate inference calls
tags: infer, caching, latency
---

## Cache Responses by User Context with a Short TTL

A seeker who reloads the homepage three times in ten seconds does not need three fresh inference calls — the recommendations should stay stable within a session. Caching GetRecommendations responses by a composite key of `(userId, surface, context)` with a short TTL (30-120 seconds) reduces Personalize cost, preserves session continuity (the same listings appear in the same order) and cuts latency. The TTL must be short enough that a real preference change (booking, dismissal) invalidates the cache within a reasonable window.

**Incorrect (every request fires a fresh GetRecommendations call):**

```python
def homefeed(seeker: Seeker, surface: str) -> list[Listing]:
    response = personalize_runtime.get_recommendations(
        campaignArn=CAMPAIGN_ARN,
        userId=seeker.id,
        numResults=24,
        context={"SURFACE": surface},
    )
    return hydrate_listings(response["itemList"])
```

**Correct (short-TTL cache keyed on user + surface + context hash):**

```python
def homefeed(seeker: Seeker, surface: str) -> list[Listing]:
    cache_key = f"rec:{seeker.id}:{surface}:{hash_context(seeker)}"
    cached = redis.get(cache_key)
    if cached:
        return deserialize_listings(cached)

    response = personalize_runtime.get_recommendations(
        campaignArn=CAMPAIGN_ARN,
        userId=seeker.id,
        numResults=24,
        context={"SURFACE": surface},
    )
    listings = hydrate_listings(response["itemList"])
    redis.setex(cache_key, 60, serialize_listings(listings))
    return listings
```

Reference: [AWS Personalize — Real-time Item Recommendations](https://docs.aws.amazon.com/personalize/latest/dg/recommendations.html)
