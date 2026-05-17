---
title: Use Two-Tower Architecture for Embedding-Based Retrieval
impact: CRITICAL
impactDescription: enables sub-100ms recall at billion-item scale
tags: recall, two-tower, embeddings, ebr, knn, airbnb
---

## Use Two-Tower Architecture for Embedding-Based Retrieval

A single-encoder cross-attention model that scores every (query, item) pair at request time is O(N) and impossible at marketplace scale. The two-tower design splits the model: the **item tower** (listing features, amenities, historical engagement) is computed offline daily and indexed into an ANN store; the **query tower** (search location, dates, guests) is computed online per request and used as the kNN probe vector. Airbnb's EBR system (Abdool et al. 2025) uses this exact pattern.

**Incorrect (online cross-encoder, infeasible above ~10k candidates):**

```python
# Score every candidate at request time — 50ms × N items
def rank(query, candidates):
    return sorted(
        candidates,
        key=lambda item: cross_encoder.score(query, item),
        reverse=True
    )
```

**Correct (offline item embeddings + online query embedding):**

```python
# Offline daily batch — index N item vectors once
for listing in all_listings:
    vec = item_tower(listing.features)
    opensearch.index(
        index="listings",
        body={"id": listing.id, "embedding": vec, **listing.fields}
    )
```

```json
// Online — single query embedding, then ANN lookup
POST /listings/_search
{
  "size": 200,
  "query": {
    "knn": {
      "embedding": {
        "vector": [/* query_tower(query_features) */],
        "k": 200
      }
    }
  }
}
```

**Index mapping with HNSW:**

```json
PUT /listings
{
  "settings": { "index.knn": true },
  "mappings": {
    "properties": {
      "embedding": {
        "type": "knn_vector",
        "dimension": 128,
        "method": {
          "name": "hnsw",
          "engine": "lucene",
          "parameters": { "ef_construction": 256, "m": 16 }
        }
      }
    }
  }
}
```

**When NOT to use this pattern:** If your catalogue is small (<100k items) and your latency budget allows full cross-encoder scoring, the gains from two-tower are smaller than the operational complexity of training, batch-embedding, and ANN-indexing.

Reference: [Embedding-Based Retrieval for Airbnb Search (Abdool et al., 2025)](https://arxiv.org/pdf/2601.06873) · [Airbnb Engineering: EBR for Search](https://airbnb.tech/uncategorized/embedding-based-retrieval-for-airbnb-search/)
