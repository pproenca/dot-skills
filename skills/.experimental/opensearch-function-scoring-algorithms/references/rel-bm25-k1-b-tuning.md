---
title: Tune BM25 k1 and b Per-Field for Short Marketplace Documents
impact: HIGH
impactDescription: 5-15% NDCG@10 lift on title fields
tags: rel, bm25, similarity, k1, b, length-normalization
---

## Tune BM25 k1 and b Per-Field for Short Marketplace Documents

The default BM25 parameters (`k1=1.2`, `b=0.75`) are tuned for TREC-style ~500-token documents. Marketplace fields range from 5-token titles to 1000-token descriptions; one-size parameters under-perform on both ends. `k1` controls how fast term-frequency saturates (lower = saturate sooner — appropriate for short fields where one occurrence is meaningful); `b` controls length-normalization aggressiveness (lower = penalize long docs less — appropriate for fields where document length varies legitimately).

**Incorrect (one similarity for every field, default values):**

```json
PUT /listings
{
  "mappings": {
    "properties": {
      "title":       { "type": "text" },
      "description": { "type": "text" },
      "amenities":   { "type": "text" }
    }
  }
}
```

**Correct (per-field similarities tuned for field length distribution):**

```json
PUT /listings
{
  "settings": {
    "index": {
      "similarity": {
        "bm25_title":  { "type": "BM25", "k1": 0.5, "b": 0.85 },
        "bm25_desc":   { "type": "BM25", "k1": 1.6, "b": 0.5  },
        "bm25_tags":   { "type": "BM25", "k1": 0.3, "b": 0.0  }
      }
    }
  },
  "mappings": {
    "properties": {
      "title":       { "type": "text", "similarity": "bm25_title" },
      "description": { "type": "text", "similarity": "bm25_desc" },
      "amenities":   { "type": "text", "similarity": "bm25_tags" }
    }
  }
}
```

**Tuning logic:**

| Field shape | k1 | b | Rationale |
|-------------|-----|---|-----------|
| Short, dense (title, neighborhood) | 0.3-0.7 | 0.7-0.9 | Saturate fast; length variation = noise |
| Long, prose (description) | 1.2-1.8 | 0.4-0.6 | Reward repeated emphasis; don't punish long-but-good descriptions |
| Tag list (amenities, categories) | 0.2-0.5 | 0.0 | Each tag is binary present/absent; don't length-normalize tag lists |

**Setting `b=0` for tag fields is the under-known trick:** A listing with 30 amenities should not be penalized vs one with 5; the tag list is enumerated, not narrative. Length normalization actively hurts ranking on these.

**Validation:** Always re-tune against a graded judgment set; never copy these numbers blindly. They are starting points, not answers.

Reference: [OpenSearch similarity module](https://opensearch.org/docs/latest/search-plugins/searching-data/similarity/) · [BM25 The Next Generation of Lucene Relevance (Elastic blog)](https://www.elastic.co/blog/practical-bm25-part-3-considerations-for-picking-b-and-k1-in-elasticsearch)
