---
title: Model Capacity Constraints at Rank Time
impact: HIGH
impactDescription: prevents over-saturation of popular providers
tags: match, capacity, constraints
---

## Model Capacity Constraints at Rank Time

In a marketplace with finite provider capacity, a top-ranked provider becomes less valuable as their remaining slots fill — their marginal value decays with every booking. Ranking that ignores this treats a provider with one remaining slot identically to one with ten, oversells the popular supply and leaves the long tail invisible. The fix is capacity-aware scoring: discount each provider's score by a function of remaining capacity so rank naturally rotates toward open inventory.

**Incorrect (static score, no awareness of remaining capacity):**

```python
def rank(seeker: Seeker, candidates: list[Listing]) -> list[Listing]:
    scores = {
        listing.id: predict_mutual_fit(seeker, listing)
        for listing in candidates
    }
    return sorted(candidates, key=lambda c: -scores[c.id])
```

**Correct (capacity-discounted score, rotates toward open inventory):**

```python
def rank(seeker: Seeker, candidates: list[Listing]) -> list[Listing]:
    scores = {}
    for listing in candidates:
        base_score = predict_mutual_fit(seeker, listing)
        capacity_ratio = listing.remaining_slots / max(listing.total_slots, 1)
        scores[listing.id] = base_score * (0.3 + 0.7 * capacity_ratio)
    return sorted(candidates, key=lambda c: -scores[c.id])
```

Reference: [Recommending for a Multi-Sided Marketplace: A Multi-Objective Hierarchical Approach](https://pubsonline.informs.org/doi/10.1287/mksc.2022.0238)
