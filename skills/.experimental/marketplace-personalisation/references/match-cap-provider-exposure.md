---
title: Cap Provider Exposure to Prevent Winner-Take-All
impact: CRITICAL
impactDescription: prevents supply monopolisation
tags: match, fairness, exposure-cap
---

## Cap Provider Exposure to Prevent Winner-Take-All

Without exposure caps, a handful of highly-rated providers dominate every top-24 slot, their calendars saturate, remaining demand bounces to lower-ranked providers and the middle of the supply distribution starves of signal. Capping how often any single provider appears in a result set — or in a rolling window of requests — forces diversity at the top of the funnel and keeps secondary supply alive. This is a fairness constraint, not a penalty: it simply acknowledges that a provider who is already booked cannot absorb more demand.

**Incorrect (no exposure cap, top provider monopolises results):**

```python
def ranked_homefeed(seeker: Seeker) -> list[Listing]:
    candidates = retrieve_feasible_listings(seeker)
    scored = score_with_personalize(seeker, candidates)
    return scored[:24]
```

**Correct (round-robin cap of 2 listings per provider in the top 24):**

```python
def ranked_homefeed(seeker: Seeker) -> list[Listing]:
    candidates = retrieve_feasible_listings(seeker)
    scored = score_with_personalize(seeker, candidates)

    result: list[Listing] = []
    per_provider: dict[str, int] = {}
    for listing in scored:
        if per_provider.get(listing.provider_id, 0) >= 2:
            continue
        result.append(listing)
        per_provider[listing.provider_id] = per_provider.get(listing.provider_id, 0) + 1
        if len(result) == 24:
            break
    return result
```

Reference: [DoorDash — Homepage Recommendation with Exploitation and Exploration](https://careersatdoordash.com/blog/homepage-recommendation-with-exploitation-and-exploration/)
