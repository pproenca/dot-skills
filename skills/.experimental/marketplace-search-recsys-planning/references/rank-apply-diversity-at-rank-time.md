---
title: Apply Diversity at Rank Time, Not Retrieval
impact: MEDIUM-HIGH
impactDescription: preserves retrieval recall for diversity
tags: rank, diversity, deduplication
---

## Apply Diversity at Rank Time, Not Retrieval

Diversity constraints (no more than two listings per provider, no more than three per region, interleaving by category) should be applied at rank time, after the model has scored all candidates — not at retrieval time. Applying diversity at retrieval removes candidates before they have been scored, so the ranker loses the ability to prefer a slightly-less-diverse-but-much-more-relevant slate. The rank-time diversity pass runs after scoring as a round-robin or maximum-marginal-relevance step, which preserves both recall and the model's judgement.

**Incorrect (diversity filter applied in the retrieval query, ranker never sees the full set):**

```json
{
  "query": { "match": { "title": "dog sitter" } },
  "collapse": {
    "field": "provider_id"
  },
  "size": 24
}
```

**Correct (retrieval returns full candidate set; rank-time diversity cap applied after scoring):**

```python
def rank_and_diversify(candidates: list[ScoredListing], cap_per_provider: int = 2) -> list[Listing]:
    candidates.sort(key=lambda c: -c.score)
    result: list[Listing] = []
    per_provider: dict[str, int] = {}
    for listing in candidates:
        if per_provider.get(listing.provider_id, 0) >= cap_per_provider:
            continue
        result.append(listing)
        per_provider[listing.provider_id] = per_provider.get(listing.provider_id, 0) + 1
        if len(result) == 24:
            break
    return result
```

Reference: [DoorDash — Homepage Recommendation with Exploitation and Exploration](https://careersatdoordash.com/blog/homepage-recommendation-with-exploitation-and-exploration/)
