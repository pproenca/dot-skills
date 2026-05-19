---
title: Use bool.filter for Non-Scoring Clauses
impact: CRITICAL
impactDescription: 2-10× faster queries via filter cache
tags: search, opensearch, bool, filter, scoring, cache
---

## Use bool.filter for Non-Scoring Clauses

`bool.must` clauses contribute to the relevance score AND are filterable. `bool.filter` clauses are filterable but produce no score. Using `must` for clauses that don't need scoring (`category = "electronics"`, `price >= 50`, `in_stock = true`) is doubly wasteful: OpenSearch computes BM25 scores it then ignores, AND skips the filter cache that would make these clauses ~free after the first execution.

The filter cache is one of the biggest wins in OpenSearch performance — repeated queries with the same filters hit the cache and skip the work entirely. `must` queries don't use it.

**Incorrect (everything in must — no filter cache):**

```python
body = {
    "query": {
        "bool": {
            "must": [
                {"match": {"title": "wireless headphones"}},  # ✅ scoring matters
                {"term": {"category": "electronics"}},          # ❌ doesn't need scoring
                {"range": {"price": {"gte": 50, "lte": 500}}}, # ❌ doesn't need scoring
                {"term": {"in_stock": True}},                  # ❌ doesn't need scoring
            ]
        }
    }
}
# OpenSearch scores all 4 clauses, can't cache the 3 non-text ones
```

**Correct (text matching in must, exact constraints in filter):**

```python
body = {
    "query": {
        "bool": {
            # Scoring clauses — full-text matching contributes to ranking
            "must": [
                {"match": {"title": "wireless headphones"}},
            ],
            # Non-scoring constraints — cacheable
            "filter": [
                {"term": {"category": "electronics"}},
                {"range": {"price": {"gte": 50, "lte": 500}}},
                {"term": {"in_stock": True}},
            ],
        }
    }
}
# Filter clauses are cached by OpenSearch; subsequent identical filters are ~free
```

**The four bool sub-clauses (when to use each):**

| Clause | Contributes to score | Cached | Use when |
|--------|---------------------|--------|----------|
| `must` | Yes | No | Full-text matches that affect ranking |
| `should` | Yes (boost) | No | Optional boosts (recent docs, popular items) |
| `filter` | No | Yes | Hard constraints: category, status, range, exists |
| `must_not` | No | Yes | Exclusions: not deleted, not blocked |

**Cacheable filter examples:**

```python
"filter": [
    # Term filters — cache-friendly
    {"term": {"status": "published"}},
    {"terms": {"category": ["electronics", "computers"]}},

    # Range filters with absolute values — cache-friendly
    {"range": {"price": {"gte": 50, "lte": 500}}},

    # Exists filter — cache-friendly
    {"exists": {"field": "review_count"}},

    # Geo filters — also cache-friendly
    {"geo_bounding_box": {"location": {"top_left": [-122.5, 37.5], "bottom_right": [-122.3, 37.7]}}},
],
```

**Avoid `now` in cacheable filters:**

```python
# ❌ "now" changes every millisecond — cache never hits
"filter": [{"range": {"created_at": {"gte": "now-7d/d"}}}]

# ✅ Use day-truncated dates that change once per day — cache hits all day
"filter": [{"range": {"created_at": {"gte": "now-7d/d"}}}]  # /d truncates to day boundary
```

**The `/d` (or `/h`, `/m`) date math suffix rounds to that interval, making the resolved date stable across many requests. Pair with a 1-hour or 1-day filter cache.**

**Combine score and filter:**

```python
body = {
    "query": {
        "bool": {
            # Multi-field match contributes to score
            "must": [
                {"multi_match": {
                    "query": "wireless headphones",
                    "fields": ["title^3", "description", "brand^2"],
                }}
            ],
            # Optional boosts
            "should": [
                {"range": {"created_at": {"gte": "now-30d/d", "boost": 1.5}}},
                {"term": {"is_featured": {"value": True, "boost": 2.0}}},
            ],
            # Constraints — non-scoring
            "filter": [
                {"term": {"category": "electronics"}},
                {"range": {"price": {"gte": 0, "lte": 500}}},
                {"term": {"in_stock": True}},
            ],
            "must_not": [
                {"term": {"is_deleted": True}},
                {"terms": {"id": blocked_ids}},
            ],
        }
    }
}
```

**For pure-filter queries (no scoring needed at all):**

When no clause needs scoring (e.g., "show me all electronics under $500"), wrap in `constant_score` to skip BM25 entirely:

```python
body = {
    "query": {
        "constant_score": {
            "filter": {
                "bool": {
                    "filter": [
                        {"term": {"category": "electronics"}},
                        {"range": {"price": {"lte": 500}}},
                    ]
                }
            }
        }
    }
}
# All hits get score=1.0; no scoring work performed; filters fully cached
```

**Symptom of misused bool clauses:**
- Repeated identical queries don't get faster (cache not warming because of `must` usage)
- Query latency high on simple filters
- CPU on data nodes pegged on scoring

Reference: [OpenSearch — Bool query](https://opensearch.org/docs/latest/query-dsl/compound/bool/) | [Elasticsearch — Query and filter context](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-filter-context.html)
