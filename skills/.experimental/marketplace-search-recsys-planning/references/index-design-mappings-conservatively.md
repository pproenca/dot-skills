---
title: Design Mappings Conservatively Because Reindex Is Expensive
impact: HIGH
impactDescription: avoids full reindex downtime
tags: index, mapping, immutability
---

## Design Mappings Conservatively Because Reindex Is Expensive

OpenSearch mappings are additive — you can add new fields but cannot change the type, analyzer or multi-field layout of an existing field without reindexing the entire dataset. For a marketplace with millions of listings and an append-only interaction log, reindexing is a days-long operation with alias cut-over, dual-writes and rollback planning. The mapping decisions made in week 1 constrain every query shape for the life of the project, so treat each field as a lifetime commitment — add only what is stable, predictive and worth the migration cost to ever change.

**Incorrect (speculative fields with ambiguous types that will churn in a month):**

```json
{
  "mappings": {
    "properties": {
      "listing_id": { "type": "keyword" },
      "title": { "type": "text" },
      "metadata": { "type": "object", "enabled": true },
      "tags": { "type": "text" },
      "extra": { "type": "object", "dynamic": true }
    }
  }
}
```

**Correct (explicit, typed, stable fields with multi-field analyzer layout):**

```json
{
  "mappings": {
    "dynamic": "strict",
    "properties": {
      "listing_id": { "type": "keyword" },
      "title": {
        "type": "text",
        "analyzer": "listing_text_en",
        "fields": { "raw": { "type": "keyword" } }
      },
      "region": { "type": "keyword" },
      "price_tier": { "type": "keyword" },
      "accepts_species": { "type": "keyword" },
      "trust_score": { "type": "float" },
      "created_at": { "type": "date" }
    }
  }
}
```

Reference: [OpenSearch Documentation — Supported Field Types](https://docs.opensearch.org/latest/field-types/)
