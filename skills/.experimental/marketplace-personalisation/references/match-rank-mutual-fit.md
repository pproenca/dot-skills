---
title: Rank by Mutual Fit, Not One Side
impact: CRITICAL
impactDescription: 3-5% booking lift per Airbnb study
tags: match, mutual-fit, two-sided
---

## Rank by Mutual Fit, Not One Side

A marketplace where only the seeker's preferences drive ranking produces matches the seeker wants but the provider would reject — leading to declined requests, withdrawn listings and seeker frustration. The ranking objective must combine `P(seeker likes provider)` with `P(provider accepts seeker)`; downweighting candidates with a high predicted decline rate removes dead-end matches from the top of the results. Airbnb reported a 3.75% booking conversion lift from incorporating host preferences into search ranking.

**Incorrect (one-sided scoring, ignores provider decline probability):**

```python
def rank_listings(seeker: Seeker, candidates: list[Listing]) -> list[Listing]:
    scores = {
        listing.id: predict_seeker_affinity(seeker, listing)
        for listing in candidates
    }
    return sorted(candidates, key=lambda c: -scores[c.id])
```

**Correct (mutual-fit objective combines both sides):**

```python
def rank_listings(seeker: Seeker, candidates: list[Listing]) -> list[Listing]:
    scores = {}
    for listing in candidates:
        seeker_affinity = predict_seeker_affinity(seeker, listing)
        accept_prob = predict_provider_accept(listing.provider, seeker)
        scores[listing.id] = seeker_affinity * accept_prob
    return sorted(candidates, key=lambda c: -scores[c.id])
```

Reference: [Airbnb — Machine Learning to Detect Host Preferences](https://medium.com/airbnb-engineering/how-airbnb-uses-machine-learning-to-detect-host-preferences-18ce07150fa3)
