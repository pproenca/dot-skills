---
title: Normalise Scores Across Retrieval Primitives
impact: MEDIUM-HIGH
impactDescription: enables comparable hybrid ranking
tags: rank, normalisation, hybrid
---

## Normalise Scores Across Retrieval Primitives

BM25 scores range over unbounded positive reals, vector similarity scores range 0 to 1, personalisation scores from a recommender range over a different unbounded distribution — combining raw scores from different primitives produces arbitrary weighted sums dominated by whichever primitive has the biggest numbers. Normalising each primitive's scores (min-max to 0-1 within the batch, or L2 across the batch) makes the weights meaningful. OpenSearch's hybrid search pipeline supports this via the normalization processor with `min_max` or `l2` methods.

**Incorrect (raw BM25 and KNN scores combined by direct weighted sum):**

```python
def hybrid_rank(bm25_hits: list, knn_hits: list) -> list:
    scores = {}
    for hit in bm25_hits:
        scores[hit.id] = scores.get(hit.id, 0) + 0.5 * hit.score
    for hit in knn_hits:
        scores[hit.id] = scores.get(hit.id, 0) + 0.5 * hit.score
    return sorted(scores.items(), key=lambda kv: -kv[1])
```

**Correct (min-max normalisation per primitive before weighted combination):**

```python
def hybrid_rank(bm25_hits: list, knn_hits: list, bm25_weight: float = 0.5) -> list:
    bm25_max = max((h.score for h in bm25_hits), default=1.0)
    bm25_min = min((h.score for h in bm25_hits), default=0.0)
    knn_max = max((h.score for h in knn_hits), default=1.0)
    knn_min = min((h.score for h in knn_hits), default=0.0)

    def norm(score: float, lo: float, hi: float) -> float:
        return (score - lo) / (hi - lo) if hi > lo else 0.0

    scores = {}
    for hit in bm25_hits:
        scores[hit.id] = scores.get(hit.id, 0) + bm25_weight * norm(hit.score, bm25_min, bm25_max)
    for hit in knn_hits:
        scores[hit.id] = scores.get(hit.id, 0) + (1 - bm25_weight) * norm(hit.score, knn_min, knn_max)
    return sorted(scores.items(), key=lambda kv: -kv[1])
```

Reference: [OpenSearch Blog — Building Effective Hybrid Search](https://opensearch.org/blog/building-effective-hybrid-search-in-opensearch-techniques-and-best-practices/)
