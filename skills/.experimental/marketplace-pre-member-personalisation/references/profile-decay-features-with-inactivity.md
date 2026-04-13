---
title: Decay Profile Features with Session Inactivity
impact: MEDIUM-HIGH
impactDescription: prevents stale clicks dominating the profile
tags: profile, decay, recency
---

## Decay Profile Features with Session Inactivity

A click from 40 minutes ago in a single session is a weaker preference signal than a click from 20 seconds ago — the visitor's attention and intent have both shifted. Without time decay on in-session features, a visitor who starts by browsing Barcelona and then switches to Porto has their profile dominated by the earlier Barcelona clicks and the ranker keeps showing Barcelona listings long after the visitor moved on. Exponential decay with a half-life of a few minutes on click-derived features matches how attention actually shifts within a session and keeps the ranker tracking the current intent.

**Incorrect (equal weight on every click in the session):**

```python
def compute_region_preference(clicks: list[ClickEvent]) -> dict[str, float]:
    counts: dict[str, int] = {}
    for click in clicks:
        counts[click.region] = counts.get(click.region, 0) + 1
    total = sum(counts.values())
    return {region: count / total for region, count in counts.items()}
```

**Correct (exponential decay with a 5-minute half-life):**

```python
def compute_region_preference(clicks: list[ClickEvent], now: datetime) -> dict[str, float]:
    half_life_seconds = 300
    weights: dict[str, float] = {}
    for click in clicks:
        age_seconds = (now - click.timestamp).total_seconds()
        weight = 0.5 ** (age_seconds / half_life_seconds)
        weights[click.region] = weights.get(click.region, 0.0) + weight
    total = sum(weights.values())
    return {region: weight / total for region, weight in weights.items()} if total > 0 else {}
```

Reference: [Ensemble Contextual Bandits for Personalized Recommendation (ACM RecSys 2014)](https://dl.acm.org/doi/10.1145/2645710.2645732)
