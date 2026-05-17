---
title: Apply Cross-Encoder Re-rank on Top-50 for Personalization
impact: HIGH
impactDescription: 5-10% NDCG@10 lift on top window
tags: pers, cross-encoder, rerank, top-k, transformer
---

## Apply Cross-Encoder Re-rank on Top-50 for Personalization

Bi-encoders (two-tower) embed query and item independently — they're fast and scale to billions of items but can't model fine-grained query × item × user interactions because the encoders never see each other. Cross-encoders concatenate the inputs and pass them through a transformer, capturing rich pairwise interactions, but cost O(N) per query. The practical pattern: retrieve top-200 with the bi-encoder, re-rank top-50 with the cross-encoder. You get bi-encoder scale and cross-encoder precision on the window users actually see.

**Incorrect (only bi-encoder ranks — misses query-item interactions):**

```json
POST /listings/_search
{
  "size": 50,
  "query": {
    "knn": {
      "embedding": {
        "vector": [/* query embedding */],
        "k": 50
      }
    }
  }
}
```

**Correct (bi-encoder retrieves 200, cross-encoder re-ranks top-50):**

```python
# Stage 1: bi-encoder retrieval (fast, ANN)
candidates = opensearch.search(index="listings", body={
    "size": 200,
    "query": {"knn": {"embedding": {"vector": query_vec, "k": 200}}}
})["hits"]["hits"]

# Stage 2: cross-encoder re-rank (slow but only on 200)
from sentence_transformers import CrossEncoder
ce = CrossEncoder("cross-encoder/ms-marco-MiniLM-L-12-v2")

query_text = enriched_query(query, user_context)  # includes user features
pairs = [(query_text, listing_text(c["_source"])) for c in candidates]
ce_scores = ce.predict(pairs, batch_size=32)

# Re-rank by cross-encoder score
top_50 = [c for _, c in sorted(zip(ce_scores, candidates), key=lambda x: -x[0])][:50]
```

**Enriching the query text with user context is the personalization trick:**

```python
def enriched_query(raw_query, user):
    parts = [raw_query]
    if user.recent_clicks:
        parts.append("user recently viewed: " + ", ".join(user.recent_clicks[-3:]))
    if user.prefers:
        parts.append("user prefers: " + ", ".join(user.prefers))
    return " | ".join(parts)
```

The cross-encoder sees both the raw query and the user's session/preference context as one text input, learning to attend to relevant context when scoring each candidate.

**Latency budget at top-50:**

| Cross-encoder model | Top-200 batch | Top-50 batch |
|---------------------|---------------|--------------|
| MiniLM-L6 | ~80ms | ~25ms |
| MiniLM-L12 | ~160ms | ~50ms |
| MS-MARCO BERT base | ~600ms | ~200ms |

For sub-200ms total search latency, MiniLM-L6/L12 on top-50 is the safe zone.

**When the lift isn't worth it:** Cross-encoder gains are smallest when bi-encoder is already saturated (very small catalogue, very strong text relevance). The 5-10% NDCG gains are typical of large heterogeneous catalogues where the bi-encoder is leaving query-item interaction signal on the table.

Reference: [SBERT Cross-Encoder docs](https://www.sbert.net/examples/applications/cross-encoder/README.html) · [Reimers & Gurevych — Sentence-BERT (EMNLP 2019)](https://arxiv.org/abs/1908.10084)
