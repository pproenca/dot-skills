---
title: Layer a Process LRU in Front of Redis
impact: HIGH
impactDescription: reduces Redis RTT 30-90× for the hottest keys
tags: cache, lru, two-tier, process, redis
---

## Layer a Process LRU in Front of Redis

A Redis lookup takes ~1ms over the network. An in-process dict lookup takes ~0.001ms. For the very hottest keys (top 50 popular segments, top 100 frequently-searched terms), a small bounded LRU in front of Redis multiplies cache hits by 100× without adding load to Redis. The trade-off is staleness — process caches don't see Redis invalidations — so use this only for data that tolerates a short staleness window (10-60s).

The Pareto-style distribution of cache access (small fraction of keys serve majority of traffic) means a 1000-entry process LRU often catches 60-80% of all reads.

**Incorrect (every request hits Redis):**

```python
async def get_popular(segment: str):
    cached = await redis.get(f"popular:{segment}")
    if cached:
        return json.loads(cached)
    items = await expensive_origin_call(segment)
    await redis.setex(f"popular:{segment}", 3600, json.dumps(items))
    return items
# 10,000 RPS to the API = 10,000 RPS to Redis even when the data is highly repeated
```

**Correct (two-tier: process LRU → Redis → origin):**

```python
from cachetools import TTLCache
from threading import Lock

# Process-local LRU with TTL — kept at module scope per worker
_local_cache: TTLCache = TTLCache(maxsize=1000, ttl=30)  # 1000 keys, 30s TTL
_local_cache_lock = Lock()  # cachetools is not thread-safe by default

async def get_popular(segment: str):
    key = f"popular:{segment}"

    # Tier 1: process LRU (sub-microsecond)
    with _local_cache_lock:
        if key in _local_cache:
            return _local_cache[key]

    # Tier 2: Redis (~1ms)
    cached = await redis.get(key)
    if cached:
        value = json.loads(cached)
        with _local_cache_lock:
            _local_cache[key] = value
        return value

    # Tier 3: origin (~hundreds of ms) — protected from stampede
    value = await get_with_stampede_protection(
        key, lambda: expensive_origin_call(segment), ttl_s=3600
    )
    with _local_cache_lock:
        _local_cache[key] = value
    return value
```

**Pick the process LRU's TTL much shorter than Redis's:**

| Layer | Typical TTL | Staleness window |
|-------|-------------|------------------|
| Process LRU | 10-60s | Short — tolerated |
| Redis | 5min-1h | Medium — application-tolerated |
| Origin | (no TTL — source of truth) | None |

A short process-tier TTL bounds how stale the response can be even when other workers have already refreshed Redis. With Django + 8 gunicorn workers, each worker has its own LRU — they refresh independently.

**Don't use process LRU for user-specific data with thousands of users:**

The hit rate depends on key reuse across requests. If you have 100k users and each has their own personalized cache key, a 1000-entry LRU has a ~1% hit rate — net negative (overhead without benefit).

| Good fit | Poor fit |
|----------|----------|
| Per-segment popular (50 segments × heavy traffic each) | Per-user personalized recommendations (high cardinality, low reuse) |
| Top search terms (skewed Zipf distribution) | Cursor-paginated feed pages (each cursor unique) |
| Reference data (countries, categories, tag taxonomy) | One-off lookups (debug requests) |
| Model version / feature flag values | User profile (often unique per request) |

**Use a stale-cache pattern with background refresh:**

```python
from cachetools import TTLCache

_local_cache = TTLCache(maxsize=1000, ttl=60)
_refresh_in_progress: set[str] = set()

async def get_with_background_refresh(key: str, fetch_fn):
    """Return cached immediately; refresh in background if approaching expiry."""
    with _local_cache_lock:
        value = _local_cache.get(key)
        # Check remaining time
        expires_at = _local_cache._TTLCache__links.get(key, (0,))[0]
    if value is not None:
        # If we're within 10s of expiry and no refresh is running, kick off refresh
        remaining = expires_at - _local_cache._TTLCache__timer()
        if remaining < 10 and key not in _refresh_in_progress:
            _refresh_in_progress.add(key)
            asyncio.create_task(_refresh_local(key, fetch_fn))
        return value
    # True miss
    value = await fetch_fn()
    with _local_cache_lock:
        _local_cache[key] = value
    return value

async def _refresh_local(key: str, fetch_fn):
    try:
        value = await fetch_fn()
        with _local_cache_lock:
            _local_cache[key] = value
    finally:
        _refresh_in_progress.discard(key)
```

**Monitor the hit-rate per tier:**

```python
# Track at each layer to verify the tier is earning its complexity
metrics.increment("cache.lookup", tags={"tier": "process", "result": "hit"})
metrics.increment("cache.lookup", tags={"tier": "process", "result": "miss"})
metrics.increment("cache.lookup", tags={"tier": "redis", "result": "hit"})
metrics.increment("cache.lookup", tags={"tier": "redis", "result": "miss"})

# Good production numbers:
#   process tier: 60-80% hit rate (depends on key cardinality)
#   redis tier:   80-95% hit rate (of misses from tier 1)
```

If process-tier hit rate < 20%, remove it — the complexity isn't justified.

**Multi-worker invalidation (when stale local data is unacceptable):**

If you need an event-based invalidation (e.g., "this segment's popular items were just edited"), use Redis pub/sub:

```python
async def listen_for_invalidations():
    pubsub = redis.pubsub()
    await pubsub.subscribe("cache_invalidate")
    async for message in pubsub.listen():
        if message["type"] == "message":
            key = message["data"].decode()
            with _local_cache_lock:
                _local_cache.pop(key, None)
# Run listen_for_invalidations as a background task per worker
# Publishers call: await redis.publish("cache_invalidate", key)
```

**Symptom of missing process tier:**
- Redis CPU usage near limit during peak
- Redis network bandwidth dominates
- p99 latency dominated by Redis lookups even on hot keys

Reference: [Python — cachetools](https://cachetools.readthedocs.io/) | [Caching patterns — multi-tier](https://aws.amazon.com/builders-library/caching-challenges-and-strategies/)
