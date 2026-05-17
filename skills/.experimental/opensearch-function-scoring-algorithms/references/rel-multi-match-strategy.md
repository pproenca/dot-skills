---
title: Pick multi_match Type by Query Shape, Not by Default
impact: HIGH
impactDescription: 10-25% relevance shift between types
tags: rel, multi-match, best-fields, cross-fields, most-fields
---

## Pick multi_match Type by Query Shape, Not by Default

The `multi_match` type is the most consequential decision in `multi_match` queries, yet defaults silently to `best_fields` which is wrong for many marketplace queries. The four types model fundamentally different beliefs about how a query relates to fields: `best_fields` (one field is the right match), `most_fields` (more fields matching = more relevant), `cross_fields` (the query is a single concept split across fields), `phrase` (preserve order). Picking by query shape, not by reflex, matters.

**Incorrect (defaulting to `best_fields` for a person-name query split across `first_name`/`last_name`):**

```json
{
  "query": {
    "multi_match": {
      "query": "alice carvalho",
      "fields": ["first_name", "last_name"]
    }
  }
}
```

This treats `alice` and `carvalho` as needing to match in the *same* best field. Neither field contains both tokens, so the score collapses.

**Correct (`cross_fields` treats the query as one logical concept):**

```json
{
  "query": {
    "multi_match": {
      "query": "alice carvalho",
      "fields": ["first_name", "last_name"],
      "type": "cross_fields",
      "operator": "and"
    }
  }
}
```

**Decision table:**

| Type | Use when | Marketplace example |
|------|----------|---------------------|
| `best_fields` | The query best matches ONE field exactly | Title-heavy keyword search |
| `most_fields` | Multiple fields contain the same text (e.g., stemmed + unstemmed analyzers) | Boost stem + exact-form matches |
| `cross_fields` | Query is one concept split across structurally-similar fields | Person names, addresses, multi-part identifiers |
| `phrase` | Token order matters | Brand names like "blue bottle coffee" |
| `phrase_prefix` | Autocomplete / typeahead | Live search-as-you-type |

**Subtle trap with `cross_fields`:** It requires fields to share an analyzer. Mixing `keyword` and `text` analyzers in a `cross_fields` query silently degrades — OpenSearch falls back to per-field IDF and you lose the unified-concept semantics.

Reference: [OpenSearch multi_match types](https://opensearch.org/docs/latest/query-dsl/full-text/multi-match/) · [Elastic: multi_match types explained](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html)
