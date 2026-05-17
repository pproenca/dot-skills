---
title: Boost Cold-Start Listings with Bounded Exposure Allocation
impact: HIGH
impactDescription: enables supply growth without ranking instability
tags: market, cold-start, exploration, supply, new-listing
---

## Boost Cold-Start Listings with Bounded Exposure Allocation

New listings have no conversion data, so conversion-weighted ranking buries them — but a marketplace that buries new supply has no supply growth. The fix is bounded exploration: guarantee new listings a small, predictable share of impressions so they can accumulate signal, but cap the share so they don't crowd out proven inventory. The right framing is exposure allocation: "5% of impressions on this query type go to listings <14 days old." This is the marketplace-fairness analogue of epsilon-greedy bandit exploration.

**Incorrect (uniform new-listing boost — over-promotes weak new listings):**

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "city": "lisbon" } },
      "functions": [
        {
          "filter": { "range": { "listed_at": { "gte": "now-30d/d" } } },
          "weight": 3.0
        }
      ],
      "boost_mode": "multiply"
    }
  }
}
```

This 3× multiplier means a brand-new mediocre listing beats a 6-month-old great one — for every new listing. Result: top of page floods with low-quality new supply.

**Correct (bounded share via probabilistic injection):**

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "city": "lisbon" } },
      "functions": [
        {
          "filter": { "range": { "listed_at": { "gte": "now-14d/d" } } },
          "random_score": { "seed": 42, "field": "_seq_no" },
          "weight": 1.0
        },
        {
          "rank_feature": { "field": "market.conv_rate_30d_shrunk", "sigmoid": { "pivot": 0.03 } },
          "weight": 4.0
        }
      ],
      "score_mode": "sum",
      "boost_mode": "multiply"
    }
  }
}
```

The exploration random_score (weight 1.0) gives new listings a chance to surface; the main ranking signal (weight 4.0) ensures proven inventory still dominates. The ratio (1:4 → 20% potential exploration weight) controls the share.

**Alternative: deterministic interleaving in the rescore phase:**

```python
def inject_new_listings(ranked, new_pool, interval=10):
    """Replace every Nth slot with a top new listing."""
    result = list(ranked)
    for i, new_listing in enumerate(new_pool[:len(ranked)//interval]):
        slot = (i+1) * interval - 1
        if slot < len(result):
            result[slot] = new_listing
    return result

candidates = opensearch.search(index="listings", ...)
new_listings = opensearch.search(
    index="listings",
    body={"query": {"range": {"listed_at": {"gte": "now-14d/d"}}}, "sort": "completeness.score:desc"}
)
final = inject_new_listings(candidates, new_listings, interval=10)
```

**Calibrating exposure share:** Pick the share based on supply turnover. Marketplaces with fast supply churn (food delivery, secondhand goods) need higher new-listing share (5-15%); slow-churn marketplaces (long-term rentals, real estate) need less (1-3%).

**Why this is the marketplace pattern, not just an exploration trick:** Exploration in classic RL exists to refine the model; here it exists to refine the *marketplace* — let new supply prove itself. Without bounded exposure, the platform calcifies around incumbent supply and new sellers churn out.

**Combine with quality threshold:** Only inject new listings that pass a completeness threshold (≥5 photos, ≥100-char description, price set). Injecting incomplete new listings degrades the user experience and damages the trust your search results convey.

Reference: [Singh & Joachims — Fairness of Exposure in Rankings (KDD 2018)](https://arxiv.org/abs/1802.07281) · [Etsy Engineering — Multi-objective ranking](https://www.etsy.com/codeascraft/multi-objective-ranking-at-etsy)
