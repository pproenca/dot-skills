---
title: Enforce Provider Exposure Caps at Inference
impact: MEDIUM-HIGH
impactDescription: prevents supply-side concentration at inference
tags: infer, fairness, exposure-cap
---

## Enforce Provider Exposure Caps at Inference

Even with deduplication by canonical entity, a small set of providers can capture a disproportionate share of impressions across sessions — not in any single response, but in aggregate over a day or a region. A rolling-window exposure cap at the inference layer (e.g., "no provider appears in more than 10% of responses from a region in the last hour") is a global fairness constraint that protects long-tail supply from being starved by the most popular providers. This cap is enforced by the inference layer, not by the model.

**Incorrect (no rolling exposure tracking, short-term monopolisation possible):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    feasible = retrieve_feasible(seeker)
    ranked = rank_with_personalize(seeker, feasible)
    return dedupe_by_provider(ranked)[:24]
```

**Correct (rolling exposure map filters saturated providers at inference):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    feasible = retrieve_feasible(seeker)
    ranked = rank_with_personalize(seeker, feasible)

    window_exposure = exposure_tracker.recent_share(
        region=seeker.current_region,
        window_minutes=60,
    )
    allowed = [
        listing for listing in ranked
        if window_exposure.get(listing.provider_id, 0.0) < 0.10
    ]
    return dedupe_by_provider(allowed)[:24]
```

Reference: [Recommending for a Multi-Sided Marketplace: A Multi-Objective Hierarchical Approach](https://pubsonline.informs.org/doi/10.1287/mksc.2022.0238)
