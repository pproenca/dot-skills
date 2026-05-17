---
title: Apply Pre-Filter to kNN with Hard Constraints
impact: CRITICAL
impactDescription: prevents empty result sets with strict filters
tags: recall, knn, filter, hnsw, efficient-knn
---

## Apply Pre-Filter to kNN with Hard Constraints

Post-filtering a kNN search (retrieve top-K by vector similarity, then filter by price/availability/geo) silently returns fewer than K results — sometimes zero — when filters are restrictive. A guest searching "Lisbon, Apr 12-15, ≤€100/night" who only matches 3% of inventory will get a near-empty page despite thousands of relevant listings being in the catalogue. Use OpenSearch's **efficient k-NN filtering** to apply hard constraints during graph traversal.

**Incorrect (post-filter: kNN returns 200, filter keeps 4):**

```json
{
  "size": 200,
  "query": {
    "bool": {
      "must": [
        { "knn": { "embedding": { "vector": [/*...*/], "k": 200 } } }
      ],
      "filter": [
        { "range": { "price_per_night": { "lte": 100 } } },
        { "term":  { "city": "lisbon" } },
        { "term":  { "available_apr12_15": true } }
      ]
    }
  }
}
```

**Correct (pre-filter via `filter` inside knn — Lucene/Faiss engines, OpenSearch 2.10+):**

```json
{
  "size": 200,
  "query": {
    "knn": {
      "embedding": {
        "vector": [/*...*/],
        "k": 200,
        "filter": {
          "bool": {
            "must": [
              { "range": { "price_per_night": { "lte": 100 } } },
              { "term":  { "city": "lisbon" } },
              { "term":  { "available_apr12_15": true } }
            ]
          }
        }
      }
    }
  }
}
```

**Why this matters at marketplace scale:** Airbnb-style filters routinely cut candidate sets by 90%+. Post-filtering compounds this with HNSW's approximate nature — the top-200 by vector similarity may have zero overlap with the post-filter set, producing the dreaded "no results" page even when relevant inventory exists.

**Warning (engine compatibility):** Efficient k-NN filtering requires the `lucene` or `faiss` engine. The `nmslib` engine does not support pre-filtering — it falls back to post-filter and emits the same silent-empty bug.

Reference: [OpenSearch k-NN efficient filtering](https://opensearch.org/docs/latest/search-plugins/knn/filter-search-knn/)
