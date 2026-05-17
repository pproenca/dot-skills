---
title: Use rescore Phase for Heavy Scoring, Not bool/should at Retrieval
impact: HIGH
impactDescription: 5-20x latency reduction with same ranking quality
tags: rel, rescore, bool-should, ltr, two-phase, latency
---

## Use rescore Phase for Heavy Scoring, Not bool/should at Retrieval

Adding scoring signals via `should` clauses in the main `bool` query applies them to every matched document across every shard. For a query that matches 200k listings, even a cheap `function_score` or `rank_feature` clause runs 200k times before the top-K reduction. The `rescore` phase runs the expensive scorer *only* on the top-N from each shard (typically 100-500), then OpenSearch coordinates the global top-K. The relevance gain is usually within noise of full scoring; the latency win is 5-20×.

**Incorrect (heavy ranking signal applied to all 200k matches):**

```json
{
  "size": 50,
  "query": {
    "bool": {
      "must": { "multi_match": { "query": "loft lisbon", "fields": ["title^3", "description"] } },
      "should": [
        {
          "rank_feature": {
            "field": "booking_count_30d",
            "saturation": { "pivot": 50 }
          }
        },
        {
          "rank_feature": {
            "field": "host_response_rate",
            "saturation": { "pivot": 0.9 }
          }
        }
      ]
    }
  }
}
```

**Correct (`bool` for retrieval, `rescore` for ranking signals on top-500):**

```json
{
  "size": 50,
  "query": {
    "bool": {
      "must": { "multi_match": { "query": "loft lisbon", "fields": ["title^3", "description"] } },
      "filter": [{ "term": { "city": "lisbon" } }]
    }
  },
  "rescore": [
    {
      "window_size": 500,
      "query": {
        "score_mode": "total",
        "query_weight": 1.0,
        "rescore_query_weight": 1.0,
        "rescore_query": {
          "function_score": {
            "query": { "match_all": {} },
            "functions": [
              { "rank_feature": { "field": "booking_count_30d", "saturation": { "pivot": 50 } } },
              { "rank_feature": { "field": "host_response_rate", "saturation": { "pivot": 0.9 } } }
            ],
            "score_mode": "sum",
            "boost_mode": "replace"
          }
        }
      }
    }
  ]
}
```

**Two-phase intuition:** Retrieval is recall-bound (need to find the right documents); ranking is precision-bound (need to order them well). These are different problems with different cost structures. Conflating them via `bool/should` makes retrieval pay for ranking compute on irrelevant matches.

**Stacking rescore phases:** Multiple `rescore` blocks run in order, each refining the previous. Pattern: rescore[0] = LTR model on top-500 → rescore[1] = personalization on top-100 → rescore[2] = MMR diversity on top-50.

**Warning (window_size):** `window_size` is per-shard. If you have 16 shards and `window_size: 500`, you score 8000 documents — keep this in your latency budget.

Reference: [OpenSearch rescore](https://opensearch.org/docs/latest/query-dsl/compound/rescore/) · [Elastic: query then rescore pattern](https://www.elastic.co/guide/en/elasticsearch/reference/current/filter-search-results.html#rescore)
