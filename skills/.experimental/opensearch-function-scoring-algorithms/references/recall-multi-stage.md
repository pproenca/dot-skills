---
title: Split Retrieval into Cheap Recall and Expensive Re-rank
impact: HIGH
impactDescription: 10-100x cost reduction vs single-stage
tags: recall, multi-stage, rescore, cross-encoder, ltr
---

## Split Retrieval into Cheap Recall and Expensive Re-rank

Running an expensive scoring function (cross-encoder, LTR model, custom Painless script) over the full candidate set is wasteful — most candidates will not survive to the top window. A two-stage pipeline retrieves a wide cheap candidate set (BM25 + ANN, ~1000-5000 docs), then applies the expensive scorer only to the top-K (~100-500). This is the dominant pattern at Airbnb, Pinterest, Etsy, and Amazon.

**Incorrect (LTR plugin scoring all matched documents):**

```json
{
  "query": {
    "sltr": {
      "params": { "query_string": "ocean view loft" },
      "model": "marketplace_ltr_v3"
    }
  }
}
```

The LTR `sltr` query becomes the main query, applying the model to 100k+ matches — high CPU, high latency.

**Correct (cheap retrieval → rescore top-N with LTR):**

```json
{
  "size": 50,
  "query": {
    "bool": {
      "must": {
        "multi_match": {
          "query": "ocean view loft",
          "fields": ["title^2", "description", "amenities"]
        }
      },
      "filter": [
        { "term": { "city": "lisbon" } },
        { "term": { "available_apr12_15": true } }
      ]
    }
  },
  "rescore": {
    "window_size": 500,
    "query": {
      "rescore_query": {
        "sltr": {
          "params": { "query_string": "ocean view loft" },
          "model": "marketplace_ltr_v3"
        }
      },
      "score_mode": "total",
      "query_weight": 0.3,
      "rescore_query_weight": 1.0
    }
  }
}
```

**Pipeline pattern (3-stage):**

```text
Stage 1: BM25 + ANN retrieval        → top 5000 (cheap, distributed)
Stage 2: Rescore with LTR model       → top 500  (per-shard, moderate)
Stage 3: Cross-encoder re-rank top-K  → top 50   (single-node, expensive)
```

**Why this ordering matters:** The marginal cost of an expensive scorer per document is constant; the marginal *value* drops sharply after the top window. Spending compute on the candidate at rank 4937 to determine whether it should be rank 4936 returns nothing.

Reference: [OpenSearch rescore](https://opensearch.org/docs/latest/query-dsl/compound/rescore/) · [OpenSearch Learning to Rank plugin](https://opensearch.org/docs/latest/search-plugins/ltr/index/)
