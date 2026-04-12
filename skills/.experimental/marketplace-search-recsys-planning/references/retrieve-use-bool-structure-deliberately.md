---
title: Use bool Structure Deliberately
impact: MEDIUM-HIGH
impactDescription: prevents ambiguous clause semantics
tags: retrieve, bool, query-dsl
---

## Use bool Structure Deliberately

The four bool clauses mean distinct things: `must` contributes to score AND is required, `filter` is required but does not score, `should` contributes to score and is optional (with `minimum_should_match` controlling how many must fire), `must_not` excludes documents without scoring. Conflating them is the single most common OpenSearch query mistake — putting soft boosts in `must` when they should be in `should`, or stuffing filters into `must` and losing the filter cache. Every bool clause should be chosen deliberately with a reason noted in code review.

**Incorrect (soft preference wired as must, zero matches when it fires):**

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "dog sitter" } },
        { "term": { "region": "london" } },
        { "match": { "amenities": "garden" } }
      ]
    }
  }
}
```

**Correct (required goes to must plus filter, soft preferences to should):**

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "dog sitter" } }
      ],
      "filter": [
        { "term": { "region": "london" } }
      ],
      "should": [
        { "match": { "amenities": "garden" } },
        { "range": { "trust_score": { "gte": 4.5 } } }
      ],
      "minimum_should_match": 0
    }
  }
}
```

Reference: [OpenSearch Documentation — Boolean Query](https://docs.opensearch.org/latest/query-dsl/compound/bool/)
