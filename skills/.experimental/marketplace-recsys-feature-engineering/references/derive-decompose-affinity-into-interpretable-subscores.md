---
title: Decompose Affinity into Interpretable Subscores
impact: MEDIUM-HIGH
impactDescription: cuts rank-debug investigation time by 3-5x
tags: derive, interpretable, subscores, debuggability
---

## Decompose Affinity into Interpretable Subscores

A single opaque u2i score from a two-tower model is fast to compute but impossible to debug when ranking goes wrong. Complementing it with named subscores — fit, safety, logistics, price — that are each a narrow function of features gives product, trust, and support teams a vocabulary for explaining why a listing is ranked where it is, and makes regressions traceable. The blended score is what sorts the results; the subscores are what appears in the debug panel and the why-this-recommendation explanation shown to the sitter.

**Incorrect (single opaque score — untraceable):**

```python
def rank(listings: list[Listing], sitter: Sitter) -> list[Listing]:
    scored = [(l, two_tower.score(sitter, l)) for l in listings]
    return [l for l, _ in sorted(scored, key=lambda x: -x[1])]
    # when a listing appears in a wrong slot, nobody can explain why
```

**Correct (subscores + blend + debug panel):**

```python
@dataclass
class AffinityBreakdown:
    fit: float         # pet, experience, interests
    safety: float      # verification, insurance, reviews
    logistics: float   # availability, travel feasibility
    price: float       # budget alignment (or free, for THS-style membership)
    blended: float     # final sort key
    trace: dict        # feature contributions for debug UI

def affinity_breakdown(sitter: Sitter, listing: Listing) -> AffinityBreakdown:
    fit = fit_model.score(sitter, listing)
    safety = safety_model.score(sitter, listing)
    logistics = logistics_model.score(sitter, listing)
    price = price_model.score(sitter, listing)

    blended = 0.45 * fit + 0.25 * safety + 0.20 * logistics + 0.10 * price
    trace = {
        "fit_features": fit_model.contributions(sitter, listing),
        "safety_features": safety_model.contributions(sitter, listing),
    }
    return AffinityBreakdown(fit, safety, logistics, price, blended, trace)
```

Reference: [Netflix Research — Recommendations overview](https://research.netflix.com/research-area/recommendations)
