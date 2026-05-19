---
title: Protect Cache Misses from Stampede with a Lock
impact: HIGH
impactDescription: prevents N concurrent regenerations on cold miss
tags: cache, redis, stampede, dogpile, setnx
---

## Protect Cache Misses from Stampede with a Lock

When a popular cache key expires and 100 concurrent requests find it missing, all 100 hit the (expensive) origin to regenerate it. This is a "cache stampede" or "dogpile": the moment a hot key needs refreshing, the origin gets 100× its baseline load. For recommender backends where the origin call costs hundreds of milliseconds and burns model-inference budget, a stampede can cascade into a full outage.

The fix: only one request regenerates; the rest either wait for the result or serve the stale value briefly. Implement with Redis `SETNX` (set-if-not-exists) as a distributed lock around regeneration.

**Incorrect (naive cache — stampede on miss):**

```python
async def get_recommendations(user_id: str):
    key = f"recs:{user_id}"
    cached = await redis.get(key)
    if cached:
        return json.loads(cached)
    # 100 concurrent users all hit this path on cache expiry
    items = await expensive_origin_call(user_id)
    await redis.setex(key, 300, json.dumps(items))
    return items
```

**Correct (stampede-protected: lock + jittered TTL):**

```python
import asyncio
import json
import random
import time

async def get_with_stampede_protection(
    key: str,
    fetch_fn,
    *,
    ttl_s: int = 300,
    lock_timeout_s: int = 10,
    wait_for_lock_s: float = 2.0,
):
    """Cache get-or-fetch with stampede protection.

    Flow:
    1. Cache hit → return cached
    2. Cache miss + acquire lock → fetch and cache
    3. Cache miss + lock held by another worker → wait briefly, then read cache again
    """
    cached = await redis.get(key)
    if cached is not None:
        return json.loads(cached)

    lock_key = f"lock:{key}"
    # SETNX with TTL — atomic: only one worker gets the lock
    got_lock = await redis.set(lock_key, "1", nx=True, ex=lock_timeout_s)

    if got_lock:
        try:
            value = await fetch_fn()
            # Jittered TTL — stagger expiry to prevent simultaneous re-expirations
            ttl_with_jitter = int(ttl_s * (1 + random.uniform(-0.1, 0.1)))
            await redis.setex(key, ttl_with_jitter, json.dumps(value))
            return value
        finally:
            await redis.delete(lock_key)

    # Lost the lock race — wait briefly for the winner to populate, then read
    deadline = time.monotonic() + wait_for_lock_s
    while time.monotonic() < deadline:
        await asyncio.sleep(0.05)
        cached = await redis.get(key)
        if cached is not None:
            return json.loads(cached)

    # Lock holder is taking too long — fall through and compute it ourselves
    # (rare; only happens on legitimately slow origin or a held lock)
    return await fetch_fn()
```

**Usage as a decorator:**

```python
from functools import wraps

def cached_with_stampede(*, ttl_s: int, key_template: str):
    def decorator(fn):
        @wraps(fn)
        async def wrapper(*args, **kwargs):
            key = key_template.format(*args, **kwargs)
            return await get_with_stampede_protection(
                key,
                lambda: fn(*args, **kwargs),
                ttl_s=ttl_s,
            )
        return wrapper
    return decorator

@cached_with_stampede(ttl_s=300, key_template="recs:user:{0}")
async def get_recommendations(user_id: str):
    return await expensive_origin_call(user_id)
```

**Jittered TTL — why it matters:**

Without jitter: all keys cached in a 1-second burst expire 5 minutes later in the same 1-second burst. Even with stampede protection per key, you get a 1-second wave of regenerations. With jitter (±10%), the expirations spread over ~60 seconds, smoothing the origin load.

**Probabilistic early refresh (refresh before expiry to avoid the cliff):**

```python
async def get_with_probabilistic_refresh(key: str, fetch_fn, ttl_s: int):
    """Refresh proactively before expiry, weighted by remaining TTL.
    Reduces tail-latency on cache misses to ~zero."""
    cached = await redis.get(key)
    cached_ttl = await redis.ttl(key)

    if cached is None:
        # True miss — use stampede-protected fetch
        return await get_with_stampede_protection(key, fetch_fn, ttl_s=ttl_s)

    # Probabilistic refresh: chance grows as TTL shrinks
    # At TTL=full: 0% chance. At TTL=10% remaining: 10% chance. At TTL=0: 100%.
    refresh_chance = 1.0 - (cached_ttl / ttl_s) if cached_ttl > 0 else 1.0
    if random.random() < refresh_chance ** 4:  # ** 4 biases toward late refresh
        # Refresh in background; return cached value
        asyncio.create_task(_refresh_async(key, fetch_fn, ttl_s))

    return json.loads(cached)

async def _refresh_async(key: str, fetch_fn, ttl_s: int):
    try:
        await get_with_stampede_protection(key, fetch_fn, ttl_s=ttl_s)
    except Exception:
        pass  # background refresh can't block anything
```

**Symptom of unprotected stampede:**
- Origin call rate spikes briefly to N× baseline on cache expiry
- p99 latency has periodic spikes at cache TTL intervals
- Bills for ML inference services (Personalize, Databricks) are higher than expected — the spikes burn quota

**Configure Redis client for resilience:**

```python
import redis.asyncio as redis

redis_client = redis.from_url(
    settings.REDIS_URL,
    decode_responses=False,
    socket_timeout=0.5,         # never block on Redis IO
    socket_connect_timeout=0.5,
    retry_on_timeout=True,
    health_check_interval=30,
    max_connections=50,
)
```

If Redis itself is down or slow, the cache layer should *fall through* to the origin (degraded but functional), not propagate the Redis error to users. Wrap reads with a try/except that falls through.

Reference: [Redis — Distributed Locks](https://redis.io/docs/manual/patterns/distributed-locks/) | [DEFLATE — XFetch (probabilistic early refresh)](https://cseweb.ucsd.edu/~avattani/papers/cache_stampede.pdf)
