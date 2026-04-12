---
title: Use keyword and text as Multi-Fields
impact: HIGH
impactDescription: enables exact match and full-text on one field
tags: index, multi-field, keyword
---

## Use keyword and text as Multi-Fields

A field is often needed for two different purposes: full-text search (analyzed, tokenized, stemmed) and exact match or sort (unanalyzed, case-sensitive). Declaring the field as `text` only means you cannot sort or filter on the exact value; declaring it as `keyword` only means you lose tokenization and stemming. The multi-field pattern — one `text` analyzed sub-field plus one `keyword` unanalyzed sub-field — gives both behaviours from a single source field and is the standard OpenSearch mapping pattern for any human-readable field.

**Incorrect (text-only field — cannot sort, cannot term-filter):**

```json
{
  "mappings": {
    "properties": {
      "title": { "type": "text", "analyzer": "english" }
    }
  }
}
```

**Correct (multi-field: analyzed text plus unanalyzed keyword for sort and filter):**

```json
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "analyzer": "english",
        "fields": {
          "raw": { "type": "keyword" },
          "suggest": { "type": "completion" }
        }
      }
    }
  }
}
```

Reference: [OpenSearch Documentation — Supported Field Types](https://docs.opensearch.org/latest/field-types/)
