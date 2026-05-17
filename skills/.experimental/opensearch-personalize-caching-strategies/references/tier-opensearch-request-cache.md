---
title: Enable OpenSearch Request Cache for Aggregation-Heavy Queries
impact: MEDIUM-HIGH
impactDescription: 10-100x faster repeated aggregations at the shard level
tags: tier, opensearch, request-cache, aggregation, shard
---

## Enable OpenSearch Request Cache for Aggregation-Heavy Queries

OpenSearch's *index request cache* (also called shard-level request cache) stores entire search responses at the shard level for queries with `size:0` — the typical shape of aggregation-only queries (facet counts, histograms, dashboards). Cache entries automatically invalidate when the underlying shard changes (refresh, write, segment merge), so freshness is preserved. Non-deterministic queries (`now`, `Math.random()`, function-score with current time) are not cached. The hit cost is near-zero (response is served from a memory map); the miss is identical to running the query. The cache is OFF by default for many indexes — turn it ON for aggregation-heavy workloads.

**Incorrect (request cache disabled or unused):**

```json
PUT /listings/_settings
{
  "index.requests.cache.enable": false
}

// Or queries that don't qualify for caching:
GET /listings/_search
{
  "size": 10,         // size > 0 — request cache doesn't apply (it caches size:0 only)
  "query": { ... },
  "aggs": {
    "by_category": { "terms": { "field": "category_id" } }
  }
}
// Aggregations recomputed on every request even when results are identical.
```

**Correct (enable cache; structure queries for size:0 + use request_cache=true):**

```json
PUT /listings/_settings
{
  "index.requests.cache.enable": true
}

// Aggregation-only query: size:0 + request_cache=true
GET /listings/_search?request_cache=true
{
  "size": 0,                          // aggregations only, no hits returned
  "query": {
    "bool": {
      "filter": [                     // filter context — auto-cached at segment level
        { "term": { "country": "GB" } },
        { "range": { "price": { "gte": 50, "lte": 500 } } }
      ]
    }
  },
  "aggs": {
    "by_category": {
      "terms": { "field": "category_id", "size": 20 }
    },
    "price_histogram": {
      "histogram": { "field": "price", "interval": 50 }
    }
  }
}
// First call: full execution time (depends on data; can be 100ms-2s)
// Subsequent identical calls: served from cache in <5ms
```

**Two-stage pattern for search+aggregations:**

```typescript
async function searchWithFacets(q: string, filters: Filters, ctx: Ctx) {
  // 1. Aggregations: size:0, heavily cached by OpenSearch
  const facets = await opensearch.search({
    index: 'listings',
    body: {
      size: 0,
      query: { bool: { filter: buildFilterContext(q, filters, ctx) } },
      aggs: { ... },
    },
    request_cache: true,
  });

  // 2. Hits: size:20, NOT request-cached but uses filter-context (see tier-opensearch-filter-context)
  const hits = await opensearch.search({
    index: 'listings',
    body: {
      size: 20,
      from: filters.page * 20,
      query: buildScoredQuery(q, filters, ctx),
    },
  });

  return { facets, hits };
}
// The aggregations (which don't change with pagination) are cached across pages.
// Only the hits query re-runs on pagination, and it benefits from filter-context caching.
```

**When the cache invalidates:**
- Any write to the shard (index, update, delete)
- Refresh interval (default 1s) — cache entry tied to ReaderCacheKeyId
- Segment merge
- Explicit cache clear: `POST /listings/_cache/clear?request=true`

**The "all your dashboards use the same filter, none get cached" trap:** some queries look identical but include `now`, `now-1h`, `now-24h` time ranges that are non-deterministic. Replace with rounded bounds:

```json
// Incorrect — non-deterministic, doesn't cache:
{ "range": { "created_at": { "gte": "now-24h" } } }

// Correct — rounded to the hour, deterministic for an hour at a time:
{ "range": { "created_at": { "gte": "now/h-24h" } } }
```

**Memory budget:** the request cache uses up to 1% of node heap by default (`indices.requests.cache.size`). Increase to 5-10% for aggregation-heavy clusters; decrease for write-heavy clusters where the cache invalidates rapidly.

**Per-index control:** disable on indexes where queries are highly varied (write-heavy logs, never-repeated dashboards) and enable on stable aggregation indexes (product catalog, taxonomies).

Reference: [OpenSearch index request cache docs](https://docs.opensearch.org/latest/search-plugins/caching/request-cache/) · [OpenSearch blog: Understanding the index request cache](https://opensearch.org/blog/understanding-index-request-cache/) · [Opster: OpenSearch caches overview](https://opster.com/guides/opensearch/opensearch-basics/cache-node-request-shard-data-field-data-cache/)
