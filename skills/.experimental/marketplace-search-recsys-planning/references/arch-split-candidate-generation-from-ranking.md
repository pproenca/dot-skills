---
title: Split Candidate Generation from Ranking
impact: CRITICAL
impactDescription: enables independent tuning of retrieval and ranking
tags: arch, pipeline, candidate-generation
---

## Split Candidate Generation from Ranking

A retrieval pipeline that combines candidate generation and ranking in a single OpenSearch query locks the two concerns together — changing the ranker forces re-tuning the candidate pool, and changing the feasible-set rules forces re-tuning the ranker. The industry standard is a two-stage pipeline: retrieval returns 100-500 feasible candidates, ranking re-orders the top-K. Each stage is then tunable, testable and replaceable without touching the other. Airbnb, Pinterest, DoorDash, Etsy — all converged on this structure independently.

**Incorrect (single query mixes filter, candidate generation, and scoring):**

```python
def search(query: SearchQuery, seeker: Seeker) -> list[Listing]:
    body = {
        "query": {
            "function_score": {
                "query": {
                    "bool": {
                        "must": [{"multi_match": {"query": query.text, "fields": ["title", "description"]}}],
                        "filter": [{"term": {"region": query.region}}],
                    },
                },
                "functions": [{"field_value_factor": {"field": "trust_score"}}],
            },
        },
        "size": 24,
    }
    return opensearch.search(index="listings", body=body)["hits"]["hits"]
```

**Correct (stage 1 retrieves feasible candidates; stage 2 re-ranks top-K):**

```python
def search(query: SearchQuery, seeker: Seeker) -> list[Listing]:
    candidates = retrieve_candidates(query, seeker, limit=300)
    if not candidates:
        return fallback_ranker(query, seeker)
    ranked = rerank(candidates, seeker, query)
    return ranked[:24]

def retrieve_candidates(query: SearchQuery, seeker: Seeker, limit: int) -> list[Listing]:
    body = {
        "query": {
            "bool": {
                "must": [{"multi_match": {"query": query.text, "fields": ["title", "description"]}}],
                "filter": [{"term": {"region": query.region}}],
            },
        },
        "size": limit,
    }
    return hydrate(opensearch.search(index="listings", body=body)["hits"]["hits"])
```

Reference: [Airbnb — Real-time Personalization using Embeddings for Search Ranking (KDD 2018)](https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb)
