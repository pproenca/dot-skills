---
title: Apply MMR Rerank for Top-Window Diversity
impact: MEDIUM-HIGH
impactDescription: 3-7% session-level engagement lift
tags: div, mmr, rerank, diversity, carbonell
---

## Apply MMR Rerank for Top-Window Diversity

A pure relevance-ranked top-10 often shows the same neighborhood five times, the same price tier seven times, the same host twice. Users perceive this as "the same listing rendered in slightly different ways" and disengage. MMR (Maximal Marginal Relevance — Carbonell & Goldstein, SIGIR 1998) is a post-rank re-ranker that greedily picks the next item by trading relevance against similarity to already-picked items. It's the simplest, most-cited diversity algorithm; OpenSearch supports it natively for vector search since **3.3** (enable the `mmr_over_sample_factory` and `mmr_rerank_factory` system-generated processors via `cluster.search.enabled_system_generated_factories` before using the `ext.mmr` block on a `knn` or `neural` top-level query).

**The MMR objective:**

```text
MMR = arg max  [ λ × Rel(item, query) − (1 − λ) × max Sim(item, selected) ]
       item                                          j∈selected

  λ = 1.0 → pure relevance (no diversity)
  λ = 0.5 → balanced (typical starting point)
  λ = 0.0 → pure diversity (no relevance — bad)
```

**Incorrect (no diversity — top-10 is 7 lofts in Bairro Alto):**

```json
{
  "size": 10,
  "query": {
    "function_score": {
      "query": { "match": { "city": "lisbon" } },
      "functions": [ /* relevance signals */ ]
    }
  }
}
```

**Correct (OpenSearch native MMR re-ranker on vector search):**

```json
POST /listings/_search
{
  "size": 50,
  "query": {
    "knn": {
      "embedding": {
        "vector": [/* query vector */],
        "k": 50
      }
    }
  },
  "ext": {
    "mmr": {
      "candidates": 50,
      "diversity": 0.5,
      "vector_field": "embedding"
    }
  }
}
```

**Manual MMR re-rank in Python (when you need custom similarity):**

```python
import numpy as np

def mmr_rerank(candidates, query_vec, lambda_=0.5, top_k=10):
    """Greedy MMR — pick next item by relevance minus max-similarity-to-picked."""
    candidate_vecs = np.array([c.embedding for c in candidates])
    rel_scores = candidate_vecs @ query_vec
    selected = []
    remaining = list(range(len(candidates)))

    for _ in range(top_k):
        if not remaining:
            break
        best_i = best_score = None
        for i in remaining:
            sim_to_selected = (
                max(candidate_vecs[i] @ candidate_vecs[s] for s in selected)
                if selected else 0.0
            )
            mmr = lambda_ * rel_scores[i] - (1 - lambda_) * sim_to_selected
            if best_score is None or mmr > best_score:
                best_score, best_i = mmr, i
        selected.append(best_i)
        remaining.remove(best_i)

    return [candidates[i] for i in selected]
```

**Calibrating `λ`:**

| `λ` | Effect | When |
|-----|--------|------|
| 0.8 | Subtle diversity | Strong intent queries ("Hotel Lisbon Marriott") |
| 0.5 | Balanced (default) | Broad queries ("apartments lisbon") |
| 0.3 | Heavy diversity | Browse / explore intent |

**Apply MMR only to the top window (top-50 → top-10), not the whole result set:**

Re-ranking 5000 candidates with MMR's O(k × N) loop is expensive and pointless — diversity only matters in what the user sees. Apply MMR in the *rescore phase* on the top-50, output top-10.

**Why this beats post-hoc filtering for diversity:** "Show me one listing per neighborhood, ranked by relevance" sounds equivalent but loses information — it discards perfectly-relevant items just for being from a popular neighborhood. MMR penalizes redundancy continuously rather than thresholding, preserving rank order while spreading attribute coverage.

Reference: [Carbonell & Goldstein — The Use of MMR, Diversity-Based Reranking (SIGIR 1998)](https://www.cs.cmu.edu/~jgc/publication/The_Use_MMR_Diversity_Based_LTMIR_1998.pdf) · [OpenSearch MMR vector search (3.3+)](https://docs.opensearch.org/latest/vector-search/specialized-operations/vector-search-mmr/) · [OpenSearch blog — Improving vector search diversity through native MMR](https://opensearch.org/blog/improving-vector-search-diversity-through-native-mmr/)
