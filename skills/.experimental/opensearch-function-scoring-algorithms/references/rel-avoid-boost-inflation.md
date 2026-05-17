---
title: Avoid Field-Boost Inflation Above ~10x
impact: MEDIUM-HIGH
impactDescription: prevents single-field dominance collapse
tags: rel, boost, field-boost, scoring-dominance
---

## Avoid Field-Boost Inflation Above ~10x

Field boosts multiply that field's contribution to the final BM25 score. Inflating a boost to 50 or 100 to "make title really matter" doesn't gracefully prioritize title — it makes the title score so large that all other field signals become noise, and your scoring collapses to single-field ranking with extra latency. The relationship between boost and effective rank weight is sub-linear because BM25 scores grow logarithmically with TF-IDF; doubling the boost rarely doubles the ranking weight, but inflating it 50× definitely destroys the contribution of other fields.

**Incorrect (extreme boost — title dominates, description signal disappears):**

```json
{
  "query": {
    "multi_match": {
      "query": "ocean loft lisbon",
      "fields": ["title^100", "description^1", "amenities^1"]
    }
  }
}
```

A description that's a perfect long-form match contributes <1% of the final score. You've effectively turned a multi-field query into title-only with slower execution.

**Correct (sane boost ratios — fields meaningfully compose):**

```json
{
  "query": {
    "multi_match": {
      "query": "ocean loft lisbon",
      "fields": ["title^4", "neighborhood^3", "amenities^2", "description^1"],
      "type": "most_fields"
    }
  }
}
```

**Rule of thumb for boost ratios:**

| Ratio | When |
|-------|------|
| 1:1 to 3:1 | Fields are roughly equally informative |
| 3:1 to 5:1 | Title clearly more informative than body |
| 5:1 to 10:1 | Title is dramatically more informative |
| >10:1 | You almost certainly want a different retrieval strategy |

**If you need title-dominance, use `dis_max` not extreme boosts:**

```json
{
  "query": {
    "dis_max": {
      "queries": [
        { "match": { "title":       { "query": "ocean loft", "boost": 4 } } },
        { "match": { "description": { "query": "ocean loft", "boost": 1 } } }
      ],
      "tie_breaker": 0.3
    }
  }
}
```

`dis_max` takes the *max* per-document field score plus `tie_breaker × sum(other field scores)`, which expresses "title is the primary signal, other fields tie-break" without numerically annihilating the other fields.

Reference: [OpenSearch dis_max query](https://opensearch.org/docs/latest/query-dsl/compound/disjunction-max/) · [Elastic: boosting field clauses](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html#field-boost)
