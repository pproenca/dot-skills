---
title: Separate Searchable Fields from Display Fields
impact: HIGH
impactDescription: reduces index storage and query cost
tags: index, storage, display
---

## Separate Searchable Fields from Display Fields

An OpenSearch index that stores every listing attribute as a searchable field inflates index size, slows refresh, and makes query analysis harder. Most listing attributes are display-only: description HTML, image URLs, provider bio, formatted price strings. These belong in `_source` or a separate document store, not in indexed fields. Index only what you search on; store the rest separately and hydrate at fetch time. The separation keeps the index small enough to fit comfortably in memory and query latency low.

**Incorrect (every field indexed and searchable, including large display-only HTML):**

```json
{
  "mappings": {
    "properties": {
      "listing_id": { "type": "keyword" },
      "title": { "type": "text" },
      "description_html": { "type": "text" },
      "cover_image_url": { "type": "text" },
      "gallery_urls": { "type": "text" },
      "formatted_price_label": { "type": "text" },
      "provider_bio": { "type": "text" }
    }
  }
}
```

**Correct (searchable fields only; display fields excluded from indexing):**

```json
{
  "mappings": {
    "properties": {
      "listing_id": { "type": "keyword" },
      "title": { "type": "text", "analyzer": "listing_text_en" },
      "description": { "type": "text", "analyzer": "listing_text_en" },
      "region": { "type": "keyword" },
      "price_tier": { "type": "keyword" },
      "trust_score": { "type": "float" },
      "display_blob_ref": { "type": "keyword", "index": false }
    }
  }
}
```

Reference: [OpenSearch Documentation — Supported Field Types](https://docs.opensearch.org/latest/field-types/)
