---
title: Use function_score for Business Signals
impact: MEDIUM-HIGH
impactDescription: enables explainable business ranking
tags: rank, function-score, boosting
---

## Use function_score for Business Signals

Business signals like `trust_score`, `response_rate`, `completed_bookings` and `freshness` do not belong in the text-match query — they belong in a `function_score` that multiplies or adds to the base relevance score. The `function_score` structure is explicit, auditable and easy to A/B test: you can change one function's weight without touching any other layer. Avoid burying business signals inside a `script_score` blob; prefer `field_value_factor` or `gauss` decay functions which are type-safe and performant.

**Incorrect (business signals hacked into script_score with arbitrary weights):**

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "title": "dog sitter" } },
      "script_score": {
        "script": {
          "source": "_score * (1 + doc['trust_score'].value * 0.5) + doc['completed_bookings'].value * 0.01"
        }
      }
    }
  }
}
```

**Correct (explicit function_score with named functions and weights):**

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "title": "dog sitter" } },
      "functions": [
        {
          "field_value_factor": {
            "field": "trust_score",
            "factor": 0.3,
            "modifier": "sqrt",
            "missing": 1
          }
        },
        {
          "gauss": {
            "last_active_at": {
              "origin": "now",
              "scale": "30d",
              "decay": 0.5
            }
          }
        }
      ],
      "score_mode": "sum",
      "boost_mode": "multiply"
    }
  }
}
```

Reference: [OpenSearch Documentation — Rescore](https://docs.opensearch.org/latest/query-dsl/rescore/)
