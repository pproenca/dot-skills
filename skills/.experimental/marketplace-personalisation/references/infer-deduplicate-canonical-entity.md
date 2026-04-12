---
title: Deduplicate by Canonical Entity Before Returning
impact: MEDIUM-HIGH
impactDescription: prevents duplicate-entity erosion of trust
tags: infer, deduplication, canonical-entity
---

## Deduplicate by Canonical Entity Before Returning

A seeker who sees the same provider appear in slots 1, 3 and 7 under three different listing variants will notice — and the system will look broken. Deduplication must happen on the canonical entity (provider, household, legal entity) not just the listing ID, because a provider often has multiple sub-listings that map to the same real-world resource. Deduplication runs at the tail of the inference pipeline, after model scoring and before the response is returned.

**Incorrect (no deduplication, same provider dominates top-24):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    feasible = retrieve_feasible(seeker)
    ranked = rank_with_personalize(seeker, feasible)
    return ranked[:24]
```

**Correct (deduplicate by provider_id while preserving order):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    feasible = retrieve_feasible(seeker)
    ranked = rank_with_personalize(seeker, feasible)

    seen_providers: set[str] = set()
    deduped: list[Listing] = []
    for listing in ranked:
        if listing.provider_id in seen_providers:
            continue
        deduped.append(listing)
        seen_providers.add(listing.provider_id)
        if len(deduped) == 24:
            break
    return deduped
```

Reference: [Airbnb — Machine Learning-Powered Search Ranking of Airbnb Experiences](https://medium.com/airbnb-engineering/machine-learning-powered-search-ranking-of-airbnb-experiences-110b4b1a0789)
