---
title: Run Expensive Signals in rescore
impact: MEDIUM-HIGH
impactDescription: reduces scoring cost on full candidate set
tags: retrieve, rescore, performance
---

## Run Expensive Signals in rescore

Expensive ranking signals — script_score computations, cross-encoder re-scoring, KNN vector similarity, function_score with many functions — scale linearly with candidates, so running them on the full retrieved set is wasteful and slow. The `rescore` phase runs after the initial query and only re-scores the top-N candidates (default 10, typically 100-500), which lets the expensive signal focus where it matters and leaves the cheap initial query to prune the long tail. Always push expensive computations into rescore unless the signal needs to affect the recall set.

**Incorrect (expensive script_score runs on every candidate, high latency):**

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "title": "dog sitter" } },
      "script_score": {
        "script": {
          "source": "doc['vector'].size() == 0 ? 0 : cosineSimilarity(params.q, 'vector')"
        }
      }
    }
  }
}
```

**Correct (cheap query retrieves, expensive KNN runs only in rescore):**

```json
{
  "query": { "match": { "title": "dog sitter" } },
  "rescore": {
    "window_size": 200,
    "query": {
      "score_mode": "total",
      "rescore_query": {
        "function_score": {
          "script_score": {
            "script": {
              "source": "doc['vector'].size() == 0 ? 0 : cosineSimilarity(params.q, 'vector')"
            }
          }
        }
      }
    }
  }
}
```

Reference: [OpenSearch Documentation — Rescore](https://docs.opensearch.org/latest/query-dsl/rescore/)
