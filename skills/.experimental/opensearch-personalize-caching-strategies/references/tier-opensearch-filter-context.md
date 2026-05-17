---
title: Put Reusable Predicates in Filter Context for Segment-Level Caching
impact: MEDIUM-HIGH
impactDescription: 5-50x speedup on repeated filters via auto-caching at segment level
tags: tier, opensearch, filter-context, query-cache, bool-filter
---

## Put Reusable Predicates in Filter Context for Segment-Level Caching

OpenSearch's *query cache* (sometimes called node query cache) automatically caches filters at the Lucene segment level. The cache is opportunistic: it tracks how often a filter is reused; high-frequency filters get cached, low-frequency ones don't. For this to work, predicates must be in **filter context** (no scoring), not query context (with scoring). The difference is one line of structure — `bool.filter` instead of `bool.must` — and unlocks automatic caching for queries the application never explicitly cached. For marketplaces with stable filter predicates (country, category, status), this is free 5-50× speedup with no application changes.

**Incorrect (filters in `must` — scored, not cached):**

```json
{
  "query": {
    "bool": {
      "must": [
        { "term": { "country": "GB" } },        // <-- scored, not cached
        { "term": { "status": "active" } },     // <-- scored, not cached
        { "range": { "price": { "gte": 50, "lte": 500 } } },  // <-- scored, not cached
        { "match": { "title": "cozy apartment" } }
      ]
    }
  }
}
// `term` and `range` don't need scoring — they're filters. Putting them in `must`
// forces score computation and disables query-cache caching for them.
```

**Correct (filters in `filter`, scored predicates in `must`):**

```json
{
  "query": {
    "bool": {
      "filter": [
        { "term": { "country": "GB" } },         // <-- filter context, cacheable
        { "term": { "status": "active" } },      // <-- filter context, cacheable
        { "range": { "price": { "gte": 50, "lte": 500 } } }  // <-- filter context, cacheable
      ],
      "must": [
        { "match": { "title": "cozy apartment" } }   // <-- scored, contributes to _score
      ]
    }
  }
}
// Filters cached at segment level. Across queries that share country/status/price filters,
// only the `match` clause needs to execute. Speedup proportional to filter-execution cost.
```

**The same applies to `must_not` and `should` for non-scoring predicates:**

```json
{
  "query": {
    "bool": {
      "filter": [
        { "term": { "country": "GB" } }
      ],
      "must_not": [
        { "term": { "is_blocked": true } }      // <-- in filter-context-equivalent, cacheable
      ],
      "must": [
        { "match": { "title": "cozy" } }
      ]
    }
  }
}
```

**Bucket numerical ranges to maximise reuse:** see [key-bucket-numerical-ranges](key-bucket-numerical-ranges.md). The application cache key benefits from bucketing; so does OpenSearch's filter cache — bucketed ranges produce the SAME filter across more queries, so the cached segment-level filter result reuses.

**When the filter cache doesn't help:**
- Predicates that change per request (geo distance from user, time-since-creation): few segments cache them
- Very-high-cardinality filters (one user_id per request): never reused, cache wastes space

**OpenSearch node setting:**

```yaml
# elasticsearch.yml / opensearch.yml
indices.queries.cache.size: 10%   # default 10% of heap; can increase to 20%
```

**Tracking effectiveness:**

```bash
# Per-node cache stats
GET /_nodes/stats/indices/query_cache?pretty
# Look for:
#   hit_count: how many queries hit the cache
#   miss_count: how many populated the cache
#   evictions: how often the cache had to make room
#   memory_size_in_bytes: actual usage vs limit

# Aim for hit_ratio > 0.5 on aggregation-heavy nodes
# evictions should be low (high evictions = cache too small for working set)
```

**Don't put scored predicates in filter context.** A `match`, `multi_match`, or `function_score` in `filter` is silently turned into "must match" with score=1.0 — the search result still works, but every document scores the same and you've broken relevance. Only use filter context for `term`, `terms`, `range`, `exists`, `prefix` (when used as filters), `match_all`, and `geo_*` predicates.

**Combine with request cache:** filter cache is per-segment, automatic, applies to all queries. Request cache is per-query, opt-in (`request_cache=true`), applies to `size:0`. They stack — an aggregation query benefits from both.

Reference: [OpenSearch query DSL: filter context](https://docs.opensearch.org/latest/query-dsl/query-filter-context/) · [BigData Boutique: properly use Elasticsearch query cache](https://bigdataboutique.com/blog/properly-use-elasticsearch-query-cache-to-accelerate-search-performance-9566ad) · [OpenSource Connections: Caching in Elasticsearch](https://opensourceconnections.com/blog/2017/07/10/caching_in_elasticsearch/)
