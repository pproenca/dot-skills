---
title: Enable request_cache for Repeat Queries
impact: HIGH
impactDescription: 10-100× faster for hot identical queries
tags: search, opensearch, cache, request-cache, aggregations
---

## Enable request_cache for Repeat Queries

OpenSearch can cache the *response* (specifically the shard-level results) of an identical query, returning the result in microseconds without re-executing. The cache is enabled by default for aggregation-only queries (`size: 0`) but NOT for queries returning hits — you must opt in. For high-traffic API endpoints serving common search terms or filter combinations, this turns a 50ms query into a 0.5ms query for the cache-hit case.

Cache keys are based on the *entire request body*, so any tiny variation defeats the cache. Pair with [[cache-deterministic-keys]] thinking: canonicalize the request body before sending.

**Incorrect (cache disabled by default for hit queries):**

```python
def search(query: str, category: str):
    body = {
        "query": {
            "bool": {
                "must": [{"match": {"title": query}}],
                "filter": [{"term": {"category": category}}],
            }
        },
        "size": 20,
        "sort": [{"_score": "desc"}, {"_id": "asc"}],
    }
    return opensearch.search(index="products_live", body=body)
# Identical search by 100 users → 100 full query executions
```

**Correct (opt in to request cache):**

```python
def search(query: str, category: str):
    body = {
        "query": {...},
        "size": 20,
        "sort": [{"_score": "desc"}, {"_id": "asc"}],
    }
    return opensearch.search(
        index="products_live",
        body=body,
        request_cache=True,   # ✅ opt in
        # Alternative: pass via URL params
    )
# Identical search by 100 users → 1 query execution + 99 cache hits
```

**Cache invalidation:**
- Automatically invalidated when the underlying index changes (any document indexed/updated/deleted)
- Doesn't survive index refreshes
- Cache size capped per node (`indices.requests.cache.size`, default 1% of heap) — LRU eviction

**For aggregation-heavy endpoints (cache always enabled):**

```python
# Facets endpoint — pure aggregations
def get_facets(filters: dict):
    body = {
        "size": 0,                          # ✅ no hits — cache enabled by default
        "query": {"bool": {"filter": [...]}},
        "aggs": {
            "categories": {"terms": {"field": "category"}},
            "price_ranges": {"range": {"field": "price", "ranges": [...]}},
            "brands": {"terms": {"field": "brand", "size": 30}},
        },
    }
    return opensearch.search(index="products_live", body=body)
```

**Canonicalize request bodies for higher cache hit rate:**

The cache hashes the *exact* request bytes. Tiny variations defeat it:

```python
# These bodies are semantically identical but generate different cache keys:
body_a = {"query": {"bool": {"must": [...], "filter": [...]}}}
body_b = {"query": {"bool": {"filter": [...], "must": [...]}}}  # different key order
body_c = {"query": {"bool": {"must": [...], "filter": [...]}}, "size": 20}  # extra field

# Canonicalize before sending:
import json

def canonical_body(body: dict) -> dict:
    """Stable structure for cache hits — same logical query = same bytes."""
    return json.loads(json.dumps(body, sort_keys=True))  # sorts all dict keys

opensearch.search(body=canonical_body(body), request_cache=True)
```

**Avoid time-dependent values that defeat the cache:**

```python
# ❌ "now" changes every millisecond — cache never reused
"filter": [{"range": {"created_at": {"gte": "now-7d"}}}]

# ✅ Day-truncated — cache hits all day
"filter": [{"range": {"created_at": {"gte": "now-7d/d"}}}]
```

**Per-query opt-out (when invalidation cost > cache benefit):**

For queries that depend on rapidly-changing fields (inventory, real-time pricing), the cache would invalidate constantly. Opt out:

```python
opensearch.search(body=body, request_cache=False)  # skip cache for this call
```

**Tune cache size when justified:**

```yaml
# elasticsearch.yml / opensearch.yml
indices.requests.cache.size: 5%   # default is 1% of heap — increase for read-heavy
indices.requests.cache.expire: 1h  # max age before eviction (rarely needed)
```

**Combine with query result caching at the Django layer:**

The OpenSearch request cache speeds up identical-body queries. For an API serving the same response to many users (popular products, common filters), add a Redis cache layer in front of OpenSearch (see [[cache-redis-with-stampede-protection]]). Two-tier caching:

```text
Django request → Redis cache (5min TTL) → OpenSearch (with request_cache=true)
                  ↑ ~1ms hit             ↑ ~0.5ms cache hit, ~50ms miss
```

**Verify the cache is working:**

```bash
# Check cache hit rate per node
GET /_nodes/stats/indices/request_cache?pretty
# Look for: "hit_count" / ("hit_count" + "miss_count") — should be > 0.5 on hot queries
```

**Symptom of missing or broken cache:**
- Identical queries don't get faster on repeat
- `request_cache` hit rate < 10% (check via stats)
- "now" appears in filters without `/d`/`/h` truncation
- Request bodies have non-deterministic ordering

Reference: [OpenSearch — Caching](https://opensearch.org/docs/latest/search-plugins/caching/) | [Elasticsearch — Shard request cache](https://www.elastic.co/guide/en/elasticsearch/reference/current/shard-request-cache.html)
