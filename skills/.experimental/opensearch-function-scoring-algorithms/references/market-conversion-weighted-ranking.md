---
title: Weight Ranking by Conversion Rate, Not Click-Through Rate
impact: HIGH
impactDescription: 5-15% conversion lift vs CTR-only ranking
tags: market, conversion, ctr, two-sided, alignment
---

## Weight Ranking by Conversion Rate, Not Click-Through Rate

CTR optimization rewards what users click on; conversion-rate optimization rewards what they actually transact. The gap is large in marketplaces: clickbait listings (sensational title, photo) have high CTR and low conversion; trustworthy listings have moderate CTR and high conversion. Ranking by CTR pushes the catalogue toward clickbait, eroding long-term marketplace health. Ranking by conversion (booking, purchase, contact) aligns the ranking system with the business outcome that pays everyone — guests, hosts, and the platform.

**Incorrect (CTR-weighted ranking — rewards clickbait):**

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "title": "loft" } },
      "functions": [
        {
          "rank_feature": {
            "field": "ctr_30d",
            "sigmoid": { "pivot": 0.04, "exponent": 3 }
          }
        }
      ],
      "boost_mode": "multiply"
    }
  }
}
```

**Correct (conversion-rate weighted, with empirical-Bayes shrinkage):**

Compute the marketplace-conversion-rate signal with shrinkage toward category mean to handle low-sample listings:

```python
# Offline, per listing
def shrunken_conversion(listing, category_mean=0.02, m=200):
    bookings = listing.bookings_30d
    impressions = listing.impressions_30d
    if impressions == 0:
        return category_mean
    raw_cr = bookings / impressions
    return (impressions * raw_cr + m * category_mean) / (impressions + m)
```

Index as `rank_feature` and apply with `sigmoid`:

```json
PUT /listings/_mapping
{
  "properties": {
    "market": {
      "properties": {
        "conv_rate_30d_shrunk": { "type": "rank_feature", "positive_score_impact": true }
      }
    }
  }
}
```

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "title": "loft" } },
      "functions": [
        {
          "rank_feature": {
            "field": "market.conv_rate_30d_shrunk",
            "sigmoid": { "pivot": 0.03, "exponent": 3 }
          }
        }
      ],
      "boost_mode": "multiply"
    }
  }
}
```

**Why shrinkage (the `m` term) is non-negotiable:** A new listing with 1 impression and 1 booking has 100% conversion — without shrinkage it dominates ranking on noise alone. With `m=200`, that listing's score is dragged ~99% of the way back to the category mean until it accumulates real data.

**Per-segment baseline:** Compute `category_mean` per category (apartments vs hotels vs villas), per geo region, ideally per (category × region × price-tier) cell. The shrinkage prior should reflect the comparable population, not the global marketplace.

**Use CTR as a *retrieval* signal, conversion as a *ranking* signal:** CTR is fast-feedback (clicks accumulate in hours) and useful for cold-start (newer signals than bookings). Use CTR in retrieval to surface candidates that get attention; use conversion in ranking to order what wins.

Reference: [DoorDash — Search Personalization Framework (KDD 2025)](https://careersatdoordash.com/blog/doordash-kdd-llm-assisted-personalization-framework/) · [Etsy Engineering — Multi-objective ranking](https://www.etsy.com/codeascraft/multi-objective-ranking-at-etsy)
