---
title: Degrade Gracefully When OpenSearch Is Slow or Down
impact: MEDIUM-HIGH
impactDescription: prevents search outages cascading to API outages
tags: resilience, opensearch, search, fallback, degradation
---

## Degrade Gracefully When OpenSearch Is Slow or Down

OpenSearch is more reliable than ML inference services but it still goes down — shard relocations, master election failures, hot-shard saturation, version upgrades. When the search endpoint hangs, the natural failure mode (Django worker pool exhaustion via held connections) cascades to the whole API. Apply the same resilience patterns as for ML downstreams plus search-specific ones: degraded query fallback (drop the costly `function_score`, return BM25-only), cached top-N for popular searches, "empty results with a friendly message" rather than 500.

The principle: search is a *user-facing* surface. Returning 500 means "we can't help you find anything." Returning a degraded result set with a banner means "you found *something*."

**Incorrect (search failure = endpoint failure):**

```python
async def search_view(request):
    query = request.GET["q"]
    body = build_search_query(query, with_function_score=True)
    response = await opensearch.search(index="products_live", body=body)
    return JsonResponse({"items": [h["_source"] for h in response["hits"]["hits"]]})
# OpenSearch slow → request hangs → worker tied up → cascade
```

**Correct (tiered degradation with each tier doing less work):**

```python
async def search_view(request):
    query = request.GET["q"]
    cursor = decode_cursor(request.GET.get("cursor"))

    # Tier 1: full query with personalization and scoring boosts
    try:
        return await _search_full(query, request.user, cursor)
    except (OpenSearchTimeoutError, CircuitOpenError):
        logger.warning("search_degraded", tier="full", query=query)

    # Tier 2: simplified query without function_score (cheaper)
    try:
        return await _search_simple(query, cursor)
    except (OpenSearchTimeoutError, CircuitOpenError):
        logger.warning("search_degraded", tier="simple", query=query)

    # Tier 3: cached popular for the query, or empty
    cached = await _try_cached_results(query)
    if cached:
        return JsonResponse({
            "items": cached, "degraded": True, "tier": "cached",
            "message": "Showing cached results — search is temporarily limited",
        })

    return JsonResponse({
        "items": [], "degraded": True, "tier": "unavailable",
        "message": "Search is temporarily unavailable. Please try again shortly.",
    }, status=200)  # 200, not 500 — the response is still useful
```

**Tier 1 — full query:**

```python
async def _search_full(query: str, user, cursor):
    body = {
        "query": {
            "function_score": {
                "query": {
                    "bool": {
                        "must": [{"multi_match": {"query": query, "fields": ["title^3", "description"]}}],
                        "filter": [{"term": {"in_stock": True}}],
                    }
                },
                "functions": [
                    {"field_value_factor": {"field": "popularity", "modifier": "log1p"}},
                    {"gauss": {"created_at": {"origin": "now", "scale": "30d"}}},
                ],
            }
        },
        "size": 20,
        "sort": [{"_score": "desc"}, {"_id": "asc"}],
        "_source": SEARCH_LIST_FIELDS,
    }
    if cursor:
        body["search_after"] = cursor

    # Use the OpenSearch breaker — see [[protect-circuit-breaker-per-downstream]]
    response = await OPENSEARCH_BREAKER.call(
        lambda: asyncio.wait_for(
            asyncio.to_thread(opensearch.search, index="products_live", body=body),
            timeout=0.8,                  # tight timeout for tier 1
        )
    )
    return _format_response(response, degraded=False)
```

**Tier 2 — simplified query (drop the costly bits):**

```python
async def _search_simple(query: str, cursor):
    # No function_score, no filters that hit cold caches, smaller size
    body = {
        "query": {"match": {"title": query}},
        "size": 10,
        "sort": [{"_id": "asc"}],          # no scoring sort = cheaper
        "_source": SEARCH_LIST_FIELDS,
    }
    response = await OPENSEARCH_BREAKER.call(
        lambda: asyncio.wait_for(
            asyncio.to_thread(opensearch.search, index="products_live", body=body),
            timeout=1.5,                  # more headroom for degraded mode
        )
    )
    return _format_response(response, degraded=True, tier="simple")
```

**Tier 3 — cached popular results:**

```python
async def _try_cached_results(query: str) -> list[dict] | None:
    """Last-resort cache of top popular results for common queries.
    Populated by a background job."""
    canonical = query.lower().strip()
    return await redis.get(f"search_cache:{hash(canonical)}")
```

**Pre-populate the search cache for popular queries:**

```python
# Background job — runs hourly
async def warm_search_cache():
    top_queries = await analytics.get_top_search_queries(window="7d", limit=200)
    for q in top_queries:
        try:
            results = await _search_simple(q, cursor=None)
            await redis.setex(f"search_cache:{hash(q.lower().strip())}", 3600, json.dumps(results))
        except Exception:
            continue  # skip ones that fail; warm the rest
```

**Honor breaker state with friendly UI:**

```python
async def search_view(request):
    # ...
    if OPENSEARCH_BREAKER.is_open():
        # Don't even try — skip straight to cached/empty
        cached = await _try_cached_results(request.GET["q"])
        return JsonResponse({
            "items": cached or [],
            "degraded": True,
            "tier": "cached" if cached else "unavailable",
        })
    # ... try Tier 1, 2, 3
```

**Specific OpenSearch degradation patterns:**

- **Shard timeout**: set `timeout` query parameter to bound per-shard time
  ```python
  body["timeout"] = "500ms"  # per-shard timeout
  # Returns partial results from shards that responded within 500ms
  ```
- **Allow partial shard results**:
  ```python
  opensearch.search(
      index="products_live", body=body,
      allow_partial_search_results=True,  # default in 7.x+
  )
  # response.get("timed_out") tells you if some shards didn't respond
  ```
- **Preference for routing locality** (when applicable): `preference="_local"` reduces cross-node hops

**Show users what tier they're seeing:**

```python
{
    "items": [...],
    "degraded": False,            # tier 1 (full)
    "degraded": True, "tier": "simple",   # tier 2
    "degraded": True, "tier": "cached",   # tier 3
    "degraded": True, "tier": "unavailable", "items": [],
    "message": "..."               # only for degraded
}
```

The frontend can render a subtle banner ("Search results may be limited right now") on degraded responses without breaking the experience.

**Symptom of missing degradation:**
- OpenSearch hiccups → 500s in API → mobile app shows error screens
- "Search broke during the 1-hour OpenSearch incident" — no fallback existed
- Cold cache + slow OpenSearch = cascading worker exhaustion

Reference: [OpenSearch — Search timeout](https://opensearch.org/docs/latest/api-reference/search/#url-parameters) | [Allow partial results](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html#search-search-api-query-params)
