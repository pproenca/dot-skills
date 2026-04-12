---
title: Combine Search and Personalisation Scores with Normalised Weights
impact: MEDIUM
impactDescription: enables comparable hybrid ranking
tags: blend, normalisation, hybrid
---

## Combine Search and Personalisation Scores with Normalised Weights

When a surface blends search and personalisation, the two must be combined as a single ordered list — but their raw scores are on incomparable scales. Normalise each side (min-max within the batch, or rank-based) to 0-1 before computing a weighted sum, and commit the weights to config where they can be tuned via A/B testing. The blending weights become an explicit hyperparameter, not a hardcoded constant, so they can evolve as the system learns.

**Incorrect (raw scores summed directly, personalisation dominates):**

```python
def blend(search_hits: list, rec_hits: list) -> list:
    scored = {}
    for hit in search_hits:
        scored[hit.id] = hit.score
    for hit in rec_hits:
        scored[hit.id] = scored.get(hit.id, 0) + hit.score
    return sorted(scored.items(), key=lambda kv: -kv[1])
```

**Correct (min-max normalise each side, blend with configurable weight):**

```python
def blend(search_hits: list, rec_hits: list, search_weight: float = 0.6) -> list:
    def normalise(hits):
        if not hits:
            return {}
        lo = min(h.score for h in hits)
        hi = max(h.score for h in hits)
        rng = hi - lo
        return {h.id: (h.score - lo) / rng if rng > 0 else 0.0 for h in hits}

    search_norm = normalise(search_hits)
    rec_norm = normalise(rec_hits)

    candidate_ids = set(search_norm) | set(rec_norm)
    scored = {
        listing_id: (
            search_weight * search_norm.get(listing_id, 0.0)
            + (1 - search_weight) * rec_norm.get(listing_id, 0.0)
        )
        for listing_id in candidate_ids
    }
    return sorted(scored.items(), key=lambda kv: -kv[1])
```

Reference: [OpenSearch Blog — Building Effective Hybrid Search](https://opensearch.org/blog/building-effective-hybrid-search-in-opensearch-techniques-and-best-practices/)
