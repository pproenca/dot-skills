---
title: Use Index Templates to Enforce Consistency
impact: HIGH
impactDescription: prevents mapping drift across indices
tags: index, templates, consistency
---

## Use Index Templates to Enforce Consistency

Marketplace retrieval typically runs across multiple indices — one per listing type, one per region, or one per rollover window for interaction logs. Without an index template, each new index inherits whatever defaults the creator happened to set, and mapping drift accumulates silently until queries behave differently across indices. An index template defines the shared mapping, settings and analyzers once, and every matching new index uses it automatically, eliminating drift and making schema migrations trackable.

**Incorrect (per-index mapping set at creation, drift guaranteed):**

```python
opensearch.indices.create(
    index="listings-uk",
    body={
        "mappings": {"properties": {"title": {"type": "text"}}},
        "settings": {"number_of_shards": 3},
    },
)
opensearch.indices.create(
    index="listings-fr",
    body={
        "mappings": {"properties": {"title": {"type": "text", "analyzer": "french"}}},
        "settings": {"number_of_shards": 1},
    },
)
```

**Correct (index template applied automatically to matching index names):**

```python
opensearch.indices.put_index_template(
    name="listings_template",
    body={
        "index_patterns": ["listings-*"],
        "template": {
            "settings": {"number_of_shards": 3, "number_of_replicas": 1},
            "mappings": {
                "dynamic": "strict",
                "properties": {
                    "listing_id": {"type": "keyword"},
                    "title": {
                        "type": "text",
                        "analyzer": "listing_text_en",
                        "fields": {"raw": {"type": "keyword"}},
                    },
                    "region": {"type": "keyword"},
                    "trust_score": {"type": "float"},
                },
            },
        },
    },
)
```

Reference: [OpenSearch Documentation — Creating a Custom Analyzer](https://docs.opensearch.org/latest/analyzers/custom-analyzer/)
