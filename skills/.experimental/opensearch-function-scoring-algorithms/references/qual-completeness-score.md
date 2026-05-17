---
title: Score Listing Completeness as a Quality Signal
impact: MEDIUM
impactDescription: 5-10% conversion lift on listings nudged to complete
tags: qual, completeness, content-quality, photos, profile
---

## Score Listing Completeness as a Quality Signal

Completeness — has photos, has full description, has amenity tags, has verified host, has price set — is the cheapest quality signal you have. It's available on day one before any ratings exist (no cold-start), it's perfectly observable from the listing alone (no two-sided dynamics), and it correlates strongly with conversion (incomplete listings convert ~30-50% worse). Surfacing it as a `rank_feature` both improves ranking quality and creates an organic incentive for sellers to complete their listings.

**Incorrect (no completeness signal — incomplete listings drag down result quality):**

```json
{
  "query": { "match": { "title": "loft" } }
}
```

**Correct (completeness as a small but consistent multiplier):**

Pre-compute at index time:

```python
def completeness_score(listing):
    weights = {
        "has_5plus_photos":    0.30,
        "has_description_100": 0.20,  # description ≥ 100 chars
        "has_amenities_5":     0.20,  # ≥ 5 amenity tags
        "has_price_set":       0.10,
        "host_verified":       0.10,
        "has_house_rules":     0.05,
        "has_cancellation":    0.05,
    }
    return sum(w for k, w in weights.items() if listing.get(k))  # 0.0-1.0
```

Index as `rank_feature`:

```json
PUT /listings/_mapping
{
  "properties": {
    "quality": {
      "properties": {
        "completeness": { "type": "rank_feature", "positive_score_impact": true }
      }
    }
  }
}
```

Apply with `sigmoid` to reward the high end disproportionately:

```json
{
  "query": {
    "bool": {
      "must": [{ "match": { "title": "loft" } }],
      "should": [
        {
          "rank_feature": {
            "field": "quality.completeness",
            "sigmoid": { "pivot": 0.7, "exponent": 3.0 },
            "boost": 0.5
          }
        }
      ]
    }
  }
}
```

**Why `sigmoid` with pivot=0.7:** Most listings cluster between 0.5 and 0.9 completeness. Pivot at 0.7 gives a meaningful boost to listings above that threshold without crushing the lower-middle ones.

**Use sparingly (`boost: 0.5`):** Completeness is a *signal of seriousness*, not a quality metric on its own. Over-weighting it means a complete-but-mediocre listing beats an incomplete-but-excellent one. Treat it as a tiebreaker.

**Why this is a better signal than it looks:** Completeness is robust to all the biases that plague rating-based signals (selection bias, fake reviews, low sample size). It's also actionable feedback for sellers: "your listing isn't ranking because it has 2 photos and no description" beats "your listing isn't ranking because the algorithm decided."

Reference: [Airbnb — Search Ranking and Personalization at Airbnb](https://dl.acm.org/doi/abs/10.1145/3109859.3109920) · [OpenSearch rank_feature](https://opensearch.org/docs/latest/query-dsl/specialized/rank-feature/)
