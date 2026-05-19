---
title: Serve Stale Redis Data When Fresh Fetch Fails
impact: HIGH
impactDescription: prevents transient downstream outages from breaking the API
tags: resilience, stale, redis, fallback, stale-if-error
---

## Serve Stale Redis Data When Fresh Fetch Fails

Recommendations TTL expires every 5 minutes. At minute 5, Personalize is rate-limited. The next request finds the cache empty, calls Personalize, gets 429, raises an error to the user. But: 4 minutes ago, that same user had a perfectly good Personalize response cached. If you'd kept that around as a "stale fallback," the user would have gotten *something useful* instead of an error.

The pattern: two TTLs per cache entry — `fresh_until` (when to attempt refresh) and `stale_until` (hard expiry, much longer). Between them, serve the stale value on any refresh failure. Equivalent to HTTP's `stale-if-error` directive but applied to your origin Redis instead of an HTTP cache.

**Incorrect (single TTL — cache empty on refresh failure):**

```python
async def get_recommendations(user_id: str):
    key = f"recs:{user_id}"
    cached = await redis.get(key)
    if cached:
        return json.loads(cached)
    # Cache expired — try to refresh
    try:
        items = await personalize_client.get(user_id)
        await redis.setex(key, 300, json.dumps(items))
        return items
    except RateLimitedError:
        raise  # ❌ user sees error even though we had data 1 minute ago
```

**Correct (stale-while-error fallback with two TTLs):**

```python
import time
import json

FRESH_TTL = 300       # 5 minutes — refresh after this
STALE_TTL = 86400     # 24 hours — keep around for stale-on-error

async def get_recommendations(user_id: str):
    key = f"recs:{user_id}"
    payload = await redis.get(key)

    if payload:
        entry = json.loads(payload)
        # entry: {"items": [...], "fetched_at": 1716120000, "fresh_until": 1716120300}
        now = time.time()
        if now < entry["fresh_until"]:
            return entry["items"]  # ✅ fresh

        # Stale — try to refresh, but fall back to stale on failure
        try:
            items = await personalize_client.get(user_id)
            await _store(key, items, FRESH_TTL, STALE_TTL)
            return items
        except Exception as e:
            # ✅ Origin failed — serve stale value
            logger.warning("stale_fallback", source="personalize", user_id=user_id, error=str(e))
            return entry["items"]

    # No cache at all — must fetch (failure here is a real failure)
    items = await personalize_client.get(user_id)
    await _store(key, items, FRESH_TTL, STALE_TTL)
    return items

async def _store(key: str, items: list, fresh_ttl: int, stale_ttl: int):
    entry = {
        "items": items,
        "fetched_at": int(time.time()),
        "fresh_until": int(time.time()) + fresh_ttl,
    }
    # Redis TTL = stale_ttl; "fresh_until" is checked in app code
    await redis.setex(key, stale_ttl, json.dumps(entry))
```

**Background refresh on stale read (don't make the user wait):**

```python
async def get_with_background_refresh(user_id: str):
    key = f"recs:{user_id}"
    payload = await redis.get(key)
    if not payload:
        items = await personalize_client.get(user_id)
        await _store(key, items, FRESH_TTL, STALE_TTL)
        return items

    entry = json.loads(payload)
    now = time.time()
    if now < entry["fresh_until"]:
        return entry["items"]

    # Stale — return cached immediately, refresh in background
    asyncio.create_task(_refresh_in_background(user_id, key))
    return entry["items"]

async def _refresh_in_background(user_id: str, key: str):
    try:
        items = await personalize_client.get(user_id)
        await _store(key, items, FRESH_TTL, STALE_TTL)
    except Exception:
        # Background refresh failed — don't surface
        pass
```

**Flag staleness in the response envelope:**

```python
async def get_recommendations_with_stale_signal(user_id: str):
    entry, was_stale = await _get_with_stale_marker(user_id)
    return {
        "items": entry["items"],
        "stale": was_stale,
        "fetched_at": entry["fetched_at"],
    }
# Frontend can render a subtle "last updated 2 minutes ago" indicator on stale responses
```

**Combine with [[resilience-partial-response-envelope]]:** a stale Personalize result + a fresh Databricks + a fresh OpenSearch = a partial-AND-stale response. The envelope should flag both dimensions.

**HTTP-layer equivalent for shared caches:**

```python
# For responses cached by CDNs — let them serve stale on origin error too
response["Cache-Control"] = "public, max-age=300, stale-if-error=86400"
# Compliant CDNs (Cloudflare, Fastly) serve cached responses for up to 1 day if origin returns 5xx
```

**Persist the cache across deploys (don't lose all stale data on restart):**

Process-tier caches are wiped on restart. Redis-backed stale-tier persists. If a deploy coincides with a downstream outage, Redis stale-tier saves you. Conversely, never put stale fallback only in a process-local cache.

**When NOT to serve stale:**

- Financial / billing data — user must see current state, even if it means showing an error
- Auth / permission decisions — stale permissions could let unauthorized actions
- Inventory at checkout — selling out-of-stock items creates support load

**Symptom of missing stale fallback:**
- Transient downstream blips become user-visible errors
- "Personalize had a 30-second outage and we returned 500s the whole time"
- Recovery is slow — once Personalize recovers, the cache is still empty so users keep hitting the origin

Reference: [RFC 5861 — stale-while-revalidate & stale-if-error](https://datatracker.ietf.org/doc/html/rfc5861) | [Caching strategies for resilience](https://web.dev/articles/stale-while-revalidate)
