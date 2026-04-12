---
title: Filter Infeasible Candidates Before Ranking
impact: CRITICAL
impactDescription: reduces wasted model capacity on impossible candidates
tags: match, filters, feasibility
---

## Filter Infeasible Candidates Before Ranking

A listing outside the seeker's travel radius, unavailable on their requested dates, or excluding their pet species cannot be booked — ranking such candidates wastes model capacity and clutters the output with false promises. Hard feasibility constraints (geography, availability, species, hard preferences) belong in a retrieval/candidate-generation step that runs before the ranker ever sees the listing. The ranker then optimises over a feasible set rather than learning "which infeasible listings do seekers ignore least often".

**Incorrect (ranker sees all inventory, filters applied post-rank):**

```python
def homefeed(seeker: Seeker, request: Request) -> list[Listing]:
    all_listings = catalog.list_all_active()
    ranked = rank_listings(seeker, all_listings)
    return [
        listing for listing in ranked
        if listing.region == request.region
        and listing.is_available_on(request.date_range)
    ][:24]
```

**Correct (retrieval applies hard constraints first, ranker re-scores the feasible set):**

```python
def homefeed(seeker: Seeker, request: Request) -> list[Listing]:
    feasible = catalog.search(
        region=request.region,
        available_on=request.date_range,
        accepts_species=seeker.pet_species,
    )
    ranked = rank_listings(seeker, feasible)
    return ranked[:24]
```

Reference: [Airbnb — Real-time Personalization using Embeddings for Search Ranking](https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb)
