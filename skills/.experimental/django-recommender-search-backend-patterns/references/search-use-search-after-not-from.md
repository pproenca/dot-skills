---
title: Paginate OpenSearch with search_after, Not from/size
impact: CRITICAL
impactDescription: O(N) deep pagination → O(1)
tags: search, opensearch, pagination, search-after, deep-paging
---

## Paginate OpenSearch with search_after, Not from/size

`from=10000&size=20` makes OpenSearch sort 10,020 documents per shard, then discard 10,000 — every page deeper is exponentially more expensive. By default, OpenSearch caps `from + size` at 10,000 via `index.max_result_window` because deep pagination is so expensive. Even at page 100, `from=2000` allocates memory for 2,020 items per shard then throws away 95% of the work.

`search_after` uses the last document's sort values as a cursor — the next query says "give me the next 20 documents after (score=4.2, _id=abc123)". OpenSearch can use the sort index to skip directly to that position, making each page O(20) instead of O(N).

**Incorrect (from/size deep pagination — O(N) per page):**

```python
def search_results(query: str, page: int, size: int = 20):
    body = {
        "query": {"match": {"title": query}},
        "from": page * size,    # ❌ at page 50, OpenSearch sorts 1020 docs then drops 1000
        "size": size,
        "sort": [{"_score": "desc"}],
    }
    return opensearch.search(index="products", body=body)

# At page 500: from=10000 — hits index.max_result_window limit, query fails
```

**Correct (search_after cursor — O(1) per page regardless of depth):**

```python
def search_results(query: str, cursor: list | None = None, size: int = 20):
    body = {
        "query": {"match": {"title": query}},
        "size": size,
        # Sort must include a unique tiebreaker so the cursor is stable
        "sort": [
            {"_score": "desc"},
            {"_id": "asc"},   # tiebreaker — see [[search-stable-tiebreaker-sort]]
        ],
    }
    if cursor is not None:
        body["search_after"] = cursor

    response = opensearch.search(index="products", body=body)
    hits = response["hits"]["hits"]

    # Build cursor from the last hit's sort values
    next_cursor = hits[-1]["sort"] if hits and len(hits) == size else None
    return {
        "items": [h["_source"] for h in hits],
        "next_cursor": next_cursor,  # opaque to the API client
    }
```

**Encode the cursor opaquely (don't expose sort values to clients):**

```python
import base64, json

def encode_cursor(sort_values: list) -> str:
    return base64.urlsafe_b64encode(
        json.dumps(sort_values).encode()
    ).decode().rstrip("=")

def decode_cursor(cursor: str | None) -> list | None:
    if not cursor:
        return None
    try:
        padded = cursor + "=" * (-len(cursor) % 4)
        return json.loads(base64.urlsafe_b64decode(padded))
    except (ValueError, json.JSONDecodeError):
        return None  # malformed cursor → start from beginning

# DRF view
@api_view(["GET"])
def search(request):
    cursor = decode_cursor(request.GET.get("cursor"))
    size = min(int(request.GET.get("size", "20")), 100)
    results = search_results(request.GET["q"], cursor=cursor, size=size)
    return Response({
        "items": results["items"],
        "next_cursor": encode_cursor(results["next_cursor"]) if results["next_cursor"] else None,
    })
```

**Why opaque encoding matters:**
- Hides the underlying sort schema — you can change it without breaking API contracts
- Prevents clients from constructing cursors to inject unauthorized sort values
- Signals "this is not parseable" — clients can't try to skip ahead

**When you still need offset-based pagination:**

For admin tables with stable result sets and shallow pagination (first 10 pages), `from/size` is fine. For feeds, search, recommendations — anywhere data changes between page fetches — use `search_after`.

**The `Point In Time (PIT)` extension for consistent pagination across writes:**

If you need a snapshot view across long-running pagination (e.g., a CSV export of all matches), use PIT:

```python
# 1. Open a point-in-time
pit = opensearch.create_point_in_time(index="products", keep_alive="5m")
pit_id = pit["pit_id"]

# 2. Use it across all pages
cursor = None
while True:
    body = {
        "query": {...},
        "size": 100,
        "pit": {"id": pit_id, "keep_alive": "5m"},
        "sort": [{"_score": "desc"}, {"_id": "asc"}],
    }
    if cursor:
        body["search_after"] = cursor
    response = opensearch.search(body=body)
    if not response["hits"]["hits"]:
        break
    yield from response["hits"]["hits"]
    cursor = response["hits"]["hits"][-1]["sort"]

# 3. Close it when done
opensearch.delete_point_in_time(body={"pit_id": pit_id})
```

**Don't use `scroll` for user-facing pagination:** the `scroll` API is for bulk export, not pagination. It's stateful, holds resources on every shard for the scroll's lifetime, and is deprecated in favor of PIT + search_after.

**Symptom of deep pagination problems:**
- Search latency increases linearly with page depth
- `"too_many_clauses"` or "Result window is too large" errors after page ~100
- Memory pressure on data nodes correlating with high-page-number queries

Reference: [OpenSearch — Paginating results](https://opensearch.org/docs/latest/search-plugins/searching-data/paginate/) | [Elasticsearch — search_after](https://www.elastic.co/guide/en/elasticsearch/reference/current/paginate-search-results.html#search-after)
