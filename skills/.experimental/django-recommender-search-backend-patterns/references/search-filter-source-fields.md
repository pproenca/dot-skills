---
title: Restrict _source to Fields You Actually Render
impact: CRITICAL
impactDescription: reduces search response size 10-100×
tags: search, opensearch, source, payload, response-size
---

## Restrict _source to Fields You Actually Render

By default, OpenSearch returns the full indexed document for every hit in `_source`. For a product index with 50 fields (description, reviews, full specs, variants) when your search results page only renders 4 fields (id, title, thumbnail, price), you're shipping 90%+ wasted bytes. At scale: a 50KB-per-doc response × 20 hits = 1MB per search. With `_source` filtering on 4 fields: ~5KB total.

The cost compounds: bigger response → more network → more JSON parsing → more memory → slower DRF serialization. Filter `_source` to exactly the fields you need.

**Incorrect (no _source filter — ship the whole document):**

```python
def search_products(query: str):
    body = {
        "query": {"match": {"title": query}},
        "size": 20,
    }
    response = opensearch.search(index="products", body=body)
    return [hit["_source"] for hit in response["hits"]["hits"]]
# Response: ~50KB × 20 = 1MB. Most fields never rendered.
```

**Correct (whitelist required fields):**

```python
def search_products(query: str):
    body = {
        "query": {"match": {"title": query}},
        "size": 20,
        "_source": {
            "includes": ["id", "title", "thumbnail_url", "price", "rating"],
        },
    }
    response = opensearch.search(index="products", body=body)
    return [hit["_source"] for hit in response["hits"]["hits"]]
# Response: ~500 bytes × 20 = 10KB. 100× smaller.
```

**Or exclude bulky fields:**

```python
# When most fields are needed but a few are huge (e.g., a precomputed embedding vector)
body = {
    "query": {...},
    "_source": {
        "excludes": ["embedding_vector", "full_description", "_indexed_search_text"],
    },
}
```

**For different response shapes (list view vs detail view), use different field sets:**

```python
LIST_FIELDS = ["id", "title", "thumbnail_url", "price"]
CARD_FIELDS = LIST_FIELDS + ["rating", "review_count", "in_stock"]
DETAIL_FIELDS = CARD_FIELDS + ["description", "variants", "specs"]

def search(query: str, shape: str = "list"):
    fields = {"list": LIST_FIELDS, "card": CARD_FIELDS, "detail": DETAIL_FIELDS}[shape]
    return _search(query, source_fields=fields)
```

**Use `docvalue_fields` for sortable/aggregate fields:**

For numeric, date, or keyword fields used only for sorting or display (not full-text search), `docvalue_fields` is even more efficient than `_source` — it reads directly from columnar storage:

```python
body = {
    "query": {...},
    "_source": False,  # don't fetch _source at all
    "docvalue_fields": [
        {"field": "id", "format": "use_field_mapping"},
        {"field": "title.keyword"},
        {"field": "price"},
        {"field": "created_at", "format": "epoch_millis"},
    ],
}
# Then read from hit["fields"] instead of hit["_source"]:
items = [
    {k: v[0] for k, v in hit["fields"].items()}
    for hit in response["hits"]["hits"]
]
```

**Avoid the "let's just index everything in _source" trap:**

OpenSearch lets you disable `_source` entirely at index time (`"_source": {"enabled": false}`), keeping fields only in inverted indexes or doc values. This is more aggressive (you can't reindex without the source) but eliminates the bytes entirely. Reserve for very large per-doc payloads (logs, embeddings).

**For result enrichment (joining external data):**

When OpenSearch's hits need to be joined with database data for the response, fetch only the IDs from OpenSearch and load full objects from the DB:

```python
def search_then_enrich(query: str):
    # Step 1: OpenSearch returns only IDs
    body = {
        "query": {"match": {"title": query}},
        "size": 20,
        "_source": False,
        "fields": ["id"],
    }
    response = opensearch.search(index="products", body=body)
    ids = [h["fields"]["id"][0] for h in response["hits"]["hits"]]

    # Step 2: DB join for the actual rendered fields
    products = Product.objects.filter(id__in=ids).only("id", "title", "thumbnail_url", "price")
    by_id = {p.id: p for p in products}
    return [by_id[i] for i in ids if i in by_id]  # preserve search rank
```

**Symptom of missing _source filtering:**
- Search response time dominated by transfer, not query (compare `took` to wall-clock latency)
- OpenSearch cluster CPU pegged on serialization (`_source` is JSON-decoded per hit)
- Bytes-out metric grows faster than QPS

Reference: [OpenSearch — Source filtering](https://opensearch.org/docs/latest/api-reference/search/#url-parameters) | [Elasticsearch — Source filtering](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-fields.html#source-filtering)
