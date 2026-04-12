---
title: Combine BM25 and KNN via Hybrid Search
impact: MEDIUM-HIGH
impactDescription: enables semantic plus lexical recall
tags: retrieve, hybrid, knn
---

## Combine BM25 and KNN via Hybrid Search

Lexical (BM25) retrieval captures exact-term matches with high precision but misses semantic paraphrases — "pet minder" misses "animal carer". Vector (KNN) retrieval captures semantic similarity but loses exact-term precision — it may rank a distantly-related listing above a direct title match. The hybrid pattern runs both, normalises their scores, and combines via weighted average, keeping BM25's precision on exact terms AND vector recall on paraphrases. OpenSearch supports this directly with a hybrid query and a search pipeline processor for score normalisation.

**Incorrect (BM25 only — paraphrased queries miss):**

```json
{
  "query": {
    "match": { "description": "pet minder with garden" }
  }
}
```

**Correct (hybrid query with BM25 plus KNN; pipeline passed as URL parameter):**

```python
opensearch.search(
    index="listings",
    params={"search_pipeline": "nlp-search-pipeline"},
    body={
        "query": {
            "hybrid": {
                "queries": [
                    {"match": {"description": "pet minder with garden"}},
                    {
                        "neural": {
                            "description_embedding": {
                                "query_text": "pet minder with garden",
                                "k": 50,
                            }
                        }
                    },
                ]
            }
        }
    },
)
```

Reference: [OpenSearch Documentation — Hybrid Search](https://docs.opensearch.org/latest/vector-search/ai-search/hybrid-search/index/)
