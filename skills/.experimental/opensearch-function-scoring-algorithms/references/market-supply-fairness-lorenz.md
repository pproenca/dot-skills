---
title: Monitor Supply-Side Fairness with Lorenz/Gini Metrics
impact: HIGH
impactDescription: prevents winner-take-all supply collapse
tags: market, fairness, lorenz, gini, exposure, supply
---

## Monitor Supply-Side Fairness with Lorenz/Gini Metrics

A ranking system that optimizes only for buyer relevance concentrates exposure on a thin head — the top 5% of listings get 80% of impressions. This is mathematically optimal for user-clicked-best, but it starves the rest of the supply, who eventually churn off the platform. The Gini coefficient (or Lorenz curve area) of impression distribution is the marketplace-health metric — track it as a ranking guardrail, alert on regressions, and treat large jumps as you would a latency regression.

**The Gini coefficient over impression distribution:**

```text
Gini = 0    → perfect equality (every listing gets equal impressions)
Gini = 1    → perfect inequality (one listing gets all impressions)
Gini < 0.5  → healthy distribution
Gini > 0.7  → winner-take-all dynamic; supply at risk
```

**Incorrect (track only NDCG / conversion — blind to supply collapse):**

```python
# Daily ranking quality check — buyer-side only
def daily_ranking_health():
    return {
        "ndcg_at_10": eval_ndcg(judgment_set),
        "session_conversion": session_conversion_rate(),
    }
```

The model can win NDCG@10 while concentrating impressions to the point where new listings die — both can be true simultaneously.

**Correct (compute Gini from impression logs, alert on shifts):**

```python
import numpy as np

def gini(impressions_per_listing):
    """impressions_per_listing: 1-D array of per-listing impression counts."""
    sorted_imp = np.sort(impressions_per_listing)
    n = len(sorted_imp)
    cumimp = np.cumsum(sorted_imp)
    return (n + 1 - 2 * np.sum(cumimp) / cumimp[-1]) / n

def daily_marketplace_health():
    impressions = query_impression_logs(window="last_24h")  # dict[listing_id, count]
    counts = np.array(list(impressions.values()))
    return {
        "ndcg_at_10": eval_ndcg(judgment_set),
        "session_conversion": session_conversion_rate(),
        "exposure_gini": gini(counts),
        "p99_top_listings_share":
            sum(sorted(counts, reverse=True)[:int(len(counts) * 0.01)]) / counts.sum(),
        "active_listings_with_zero_impressions":
            sum(1 for c in counts if c == 0),
    }

# Alert thresholds — tune to your marketplace baseline
ALERT = {
    "exposure_gini": {"warn": 0.65, "critical": 0.78},
    "p99_top_listings_share": {"warn": 0.40, "critical": 0.55},
    "zero_impression_share": {"warn": 0.20, "critical": 0.35},
}
```

**Apply exposure-fairness constraint as a re-rank step:**

```python
def fairness_aware_rerank(candidates, max_per_listing_share=0.05):
    """Cap how often any single listing appears in top results across a batch."""
    impression_share = collections.Counter()
    output = []
    skipped = []
    for c in candidates:
        if impression_share[c.id] / max(len(output), 1) < max_per_listing_share:
            output.append(c)
            impression_share[c.id] += 1
        else:
            skipped.append(c)
    # Fill remaining slots from skipped pool to maintain page size
    return output + skipped[:len(candidates) - len(output)]
```

**Why this matters for buyers too, not just sellers:** Winner-take-all marketplaces present the same N listings to every user — search becomes a static directory of "the top 50." Diverse exposure ensures the catalogue feels alive, current, and locally relevant, which is what brings users back.

**Trade-off:** Improving exposure fairness costs ~1-3% short-term conversion. The long-term gain (supply retention, catalogue growth, sustained marketplace health) typically dominates. Singh & Joachims (KDD 2018) formalized this trade-off as a constrained optimization.

Reference: [Singh & Joachims — Fairness of Exposure in Rankings (KDD 2018)](https://arxiv.org/abs/1802.07281) · [Two-Sided Fairness in Rankings via Lorenz Dominance (NeurIPS 2021)](https://openreview.net/pdf?id=uPWdkoZHgba)
