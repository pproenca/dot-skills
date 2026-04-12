---
title: Use filter Clauses for Exact Matches
impact: MEDIUM-HIGH
impactDescription: enables query result caching
tags: retrieve, filter, caching
---

## Use filter Clauses for Exact Matches

OpenSearch's filter context runs clauses that do not contribute to the relevance score, and those clause results are cached per-shard — so subsequent queries that share the same filter hit the cache instead of re-evaluating. Putting exact-match conditions (region, price tier, species, active flag) into `must` instead of `filter` forces OpenSearch to compute and track scores for them, wastes CPU, and disables cache. The rule is brutal but simple: anything that is a yes/no condition without relevance implications goes in `filter`, not `must`.

**Incorrect (exact-match region in a must clause, scored and uncached):**

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "dog sitter" } },
        { "term": { "region": "london" } },
        { "term": { "active": true } }
      ]
    }
  }
}
```

**Correct (exact-match conditions in filter, scored match in must):**

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "dog sitter" } }
      ],
      "filter": [
        { "term": { "region": "london" } },
        { "term": { "active": true } }
      ]
    }
  }
}
```

Reference: [OpenSearch Documentation — Query and Filter Context](https://docs.opensearch.org/latest/query-dsl/query-filter-context/)
