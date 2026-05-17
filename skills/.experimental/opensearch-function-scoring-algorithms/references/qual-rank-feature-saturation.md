---
title: Saturate Popularity Counts with rank_feature.saturation
impact: HIGH
impactDescription: prevents popularity-blowout where 10x reviews = 10x score
tags: qual, rank-feature, saturation, popularity, normalization
---

## Saturate Popularity Counts with rank_feature.saturation

Popularity signals (review counts, booking counts, clicks) follow power-law distributions where a handful of items have orders of magnitude more activity than the long tail. Adding raw popularity into a score with `factor * count` makes head items dominate every query — search becomes "show me the top 10 most popular things, regardless of query." The `saturation` modifier maps counts through `count / (count + pivot)`, asymptoting at 1.0 as count grows; this is the mathematically clean way to express "more is better, but with diminishing returns." It's also what makes BM25's term-frequency saturate via `k1`.

**Incorrect (linear popularity — head items dominate):**

```json
{
  "query": {
    "script_score": {
      "query": { "match": { "title": "loft" } },
      "script": {
        "source": "_score + params.boost * doc['booking_count_30d'].value",
        "params": { "boost": 0.1 }
      }
    }
  }
}
```

A listing with 5000 bookings adds 500 to `_score`; one with 50 adds 5. Text relevance ranges 0-30; popularity overwhelms it.

**Correct (`rank_feature.saturation` — bounded contribution):**

```json
PUT /listings/_mapping
{
  "properties": {
    "popularity": {
      "properties": {
        "booking_count_30d": { "type": "rank_feature", "positive_score_impact": true }
      }
    }
  }
}
```

```json
{
  "query": {
    "bool": {
      "must": [{ "match": { "title": "loft" } }],
      "should": [
        {
          "rank_feature": {
            "field": "popularity.booking_count_30d",
            "saturation": { "pivot": 50 }
          }
        }
      ]
    }
  }
}
```

**Choosing `pivot`:** Pivot is the value at which the function returns 0.5. Set it to the median or geometric mean of your distribution; that way half your items score above 0.5 and half below, giving the function meaningful spread.

```text
Saturation formula:  s(x) = x / (x + pivot)

  x = pivot      → s = 0.5
  x = 5*pivot    → s ≈ 0.83
  x = 50*pivot   → s ≈ 0.98 (saturated)
```

**Auto-pivot:** Omitting the `pivot` parameter makes OpenSearch use the geometric mean of all the field's values — usually a good default.

**Why not just `log1p`?** `log1p(x)` is unbounded — it grows without limit, just slowly. `saturation` is bounded in [0,1), making it a clean weight you can multiply into other scores without surprise. Use `log1p` (via `script_score`) when you want long-tail contribution from very-high-count items; use `saturation` when you want a normalized signal.

Reference: [OpenSearch rank_feature query](https://opensearch.org/docs/latest/query-dsl/specialized/rank-feature/) · [Elastic — Boosting by relevance features](https://www.elastic.co/guide/en/elasticsearch/reference/current/rank-feature-query.html)
