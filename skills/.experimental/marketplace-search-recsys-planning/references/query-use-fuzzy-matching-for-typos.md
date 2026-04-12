---
title: Use Fuzzy Matching for Typo Tolerance
impact: MEDIUM-HIGH
impactDescription: prevents recall loss on typos
tags: query, fuzzy, typo-tolerance
---

## Use Fuzzy Matching for Typo Tolerance

A query log audit will show that roughly 10-15% of queries contain a typo — "dog siter london", "pet sittr", "walkr needed". Without fuzzy matching those queries return zero results, the session ends, and the seeker blames the product rather than their typo. OpenSearch supports Levenshtein-distance fuzzy matching via `fuzziness` on match queries: `AUTO` picks distance by term length (distance 1 for short terms, distance 2 for longer), which is the safe default for human input without catastrophically expanding irrelevant matches.

**Incorrect (exact match only — typos return zero results):**

```json
{
  "query": {
    "match": {
      "title": "dog siter"
    }
  }
}
```

**Correct (fuzzy match with AUTO distance):**

```json
{
  "query": {
    "match": {
      "title": {
        "query": "dog siter",
        "fuzziness": "AUTO",
        "prefix_length": 1,
        "max_expansions": 50
      }
    }
  }
}
```

Reference: [OpenSearch Documentation — Boolean Query](https://docs.opensearch.org/latest/query-dsl/compound/bool/)
