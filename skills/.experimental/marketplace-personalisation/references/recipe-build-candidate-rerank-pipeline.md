---
title: Build a Candidate-Generation and Re-rank Pipeline
impact: MEDIUM-HIGH
impactDescription: enables business rules and personalization to coexist
tags: recipe, pipeline, candidate-generation
---

## Build a Candidate-Generation and Re-rank Pipeline

Marketplace ranking has two distinct concerns that fight each other inside a monolithic model: hard business rules (geography, availability, compliance) and soft preference learning. A candidate-generation → re-rank pipeline separates them — the candidate generator enforces hard rules and returns a feasible set of 100-500 items, then the re-ranker applies personalisation to that set. This is how Airbnb, DoorDash and Uber structure their marketplace ranking and the structure that lets you change one layer without touching the other.

**Incorrect (monolithic call — model sees the full catalog, business rules tried post-hoc):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    response = personalize_runtime.get_recommendations(
        campaignArn=CAMPAIGN_ARN,
        userId=seeker.id,
        numResults=500,
    )
    all_ranked = hydrate_listings(response["itemList"])
    filtered = [
        listing for listing in all_ranked
        if listing.region == seeker.current_region
        and listing.is_available_today()
    ]
    return filtered[:24]
```

**Correct (retrieval → re-rank — hard rules and personalisation are separate layers):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    feasible = catalog.retrieve_feasible(
        region=seeker.current_region,
        available_on=seeker.current_date_range,
        accepts_species=seeker.pet_species,
        limit=300,
    )
    if not feasible:
        return []

    response = personalize_runtime.get_personalized_ranking(
        campaignArn=RERANK_CAMPAIGN_ARN,
        userId=seeker.id,
        inputList=[listing.id for listing in feasible],
    )
    ranked_ids = [item["itemId"] for item in response["personalizedRanking"][:24]]
    return [catalog.get(item_id) for item_id in ranked_ids]
```

Reference: [Airbnb — Real-time Personalization using Embeddings for Search Ranking](https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb)
