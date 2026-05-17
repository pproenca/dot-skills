---
title: Use Hybrid BM25 + kNN with Reciprocal Rank Fusion
impact: CRITICAL
impactDescription: 8-15% NDCG@10 lift over either alone
tags: recall, hybrid, rrf, knn, bm25, opensearch-2.19
---

## Use Hybrid BM25 + kNN with Reciprocal Rank Fusion

Lexical (BM25) and semantic (kNN over embeddings) retrievers fail on complementary queries. BM25 misses paraphrases ("brownstone" vs "townhouse"), kNN misses rare tokens (specific neighborhood names, host nicknames). Reciprocal Rank Fusion combines rankings by rank position rather than score, eliminating the need to normalize incompatible score distributions. Cormack et al. (SIGIR 2009) showed RRF beats CombMNZ, Condorcet Fuse, and individual LTR methods on LETOR 3.

**Incorrect (pure BM25, misses semantic matches):**

```json
{
  "query": {
    "multi_match": {
      "query": "cozy place near the beach",
      "fields": ["title^2", "description"]
    }
  }
}
```

**Correct (hybrid retrieval with RRF score combination):**

```json
{
  "search_pipeline": "nlp-search-pipeline",
  "query": {
    "hybrid": {
      "queries": [
        {
          "multi_match": {
            "query": "cozy place near the beach",
            "fields": ["title^2", "description"]
          }
        },
        {
          "neural": {
            "embedding": {
              "query_text": "cozy place near the beach",
              "model_id": "<embedding-model-id>",
              "k": 100
            }
          }
        }
      ]
    }
  }
}
```

Configure the pipeline with `score-ranker-processor` using `rrf` technique (OpenSearch 2.19+):

```json
PUT /_search/pipeline/nlp-search-pipeline
{
  "phase_results_processors": [
    {
      "score-ranker-processor": {
        "combination": { "technique": "rrf", "rank_constant": 60 }
      }
    }
  ]
}
```

**Why `rank_constant: 60`:** Cormack's original paper found 60 robust across collections. Lower values give more weight to top-ranked items; higher values flatten the contribution curve.

Reference: [Cormack, Clarke, Büttcher — Reciprocal Rank Fusion Outperforms Condorcet and Individual Rank Learning Methods (SIGIR 2009)](https://cormack.uwaterloo.ca/cormacksigir09-rrf.pdf) · [OpenSearch RRF docs](https://opensearch.org/blog/introducing-reciprocal-rank-fusion-hybrid-search/)
