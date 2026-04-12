---
title: Build Autocomplete on a Separate Index
impact: MEDIUM-HIGH
impactDescription: prevents autocomplete latency from blocking main search
tags: query, autocomplete, completion
---

## Build Autocomplete on a Separate Index

Autocomplete has different latency requirements and different retrieval semantics from main search — every keystroke fires a query, results must return in <50ms, and the ranking is driven by prefix match and popularity, not full relevance scoring. Running autocomplete from the same OpenSearch index as main search couples the two, so autocomplete traffic contends for the same query slots and one slow autocomplete query slows everything. A dedicated completion suggester index with a smaller denormalised document gives you single-digit millisecond latency and isolates the traffic.

**Incorrect (autocomplete served from the main listings index with match_phrase_prefix):**

```json
{
  "query": {
    "match_phrase_prefix": {
      "title": { "query": "dog sit" }
    }
  },
  "size": 10
}
```

**Correct (dedicated completion suggester on a small-footprint index):**

```json
{
  "mappings": {
    "properties": {
      "suggest": {
        "type": "completion",
        "analyzer": "simple",
        "preserve_separators": true,
        "preserve_position_increments": true,
        "max_input_length": 50
      }
    }
  }
}
```

Reference: [OpenSearch Documentation — Text Analyzers](https://docs.opensearch.org/latest/analyzers/)
