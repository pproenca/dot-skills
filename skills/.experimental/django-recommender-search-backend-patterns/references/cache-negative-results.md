---
title: Cache Negative Results to Prevent Origin Hammering
impact: MEDIUM-HIGH
impactDescription: prevents N% origin traffic from invalid IDs and empty results
tags: cache, negative, empty, 404, sentinel
---

## Cache Negative Results to Prevent Origin Hammering

A scraper, broken client, or stale URL hits `/products/xyz123` for an item that doesn't exist. The cache misses (no entry), the origin is called, the origin returns 404, you don't cache the 404 because there's "no data to cache." Next request for the same invalid ID does the same thing. With a scraper or stale CDN, you can see thousands of RPS of invalid lookups all bypassing the cache entirely.

The fix: cache the *absence* of a result too, with a short TTL. Now invalid lookups hit the cache, get an instant "not found" response, and skip the origin entirely.

**Incorrect (only cache positive results — origin hammered by repeat invalid lookups):**

```python
async def get_product(product_id: str):
    cached = await redis.get(f"product:{product_id}")
    if cached:
        return json.loads(cached)

    product = await db_or_origin.get(product_id)
    if product is None:
        return None  # ❌ not cached — every invalid request re-checks the origin

    await redis.setex(f"product:{product_id}", 3600, json.dumps(product))
    return product
```

**Correct (cache negative results with a sentinel + shorter TTL):**

```python
NOT_FOUND = "__not_found__"  # sentinel value distinguishable from a real product
NEGATIVE_TTL = 300  # 5 min — shorter than positive to allow new items to appear

async def get_product(product_id: str):
    cached = await redis.get(f"product:{product_id}")
    if cached:
        value = cached.decode() if isinstance(cached, bytes) else cached
        if value == NOT_FOUND:
            return None        # cached negative
        return json.loads(value)

    product = await db_or_origin.get(product_id)
    if product is None:
        # Cache the absence with shorter TTL
        await redis.setex(f"product:{product_id}", NEGATIVE_TTL, NOT_FOUND)
        return None

    await redis.setex(f"product:{product_id}", 3600, json.dumps(product))
    return product
```

**Pick a shorter TTL for negatives than positives:**

- Positives have a known data lineage — they don't appear from nowhere
- Negatives can flip to positive at any moment (item added, permissions changed)
- A 5-minute negative TTL means at most 5 minutes of staleness when the item appears

If your domain *never* sees negatives flip to positive (e.g., permanently-deleted item IDs), a longer negative TTL is fine.

**Cache empty result sets too:**

```python
async def search_products(query: str):
    cached = await redis.get(f"search:{hash(query)}")
    if cached is not None:
        items = json.loads(cached)
        return items  # may be []

    items = await opensearch_search(query)
    # Cache even when empty — popular zero-result searches shouldn't hit OpenSearch
    ttl = 600 if items else 60   # shorter TTL for empty results
    await redis.setex(f"search:{hash(query)}", ttl, json.dumps(items))
    return items
```

**Cache rate-limited results (treat 429 as a temporary negative):**

```python
async def call_external_with_negative_cache(key: str, fetch_fn, *, ttl_negative: int = 60):
    cached = await redis.get(key)
    if cached:
        value = json.loads(cached)
        if value.get("__error__"):
            # Re-raise the cached error
            raise CachedError(value["__error__"])
        return value

    try:
        result = await fetch_fn()
    except RateLimitedError as e:
        # Cache "we're rate-limited" briefly so we stop hammering
        await redis.setex(key, ttl_negative, json.dumps({"__error__": "rate_limited"}))
        raise
    except UnavailableError as e:
        await redis.setex(key, ttl_negative, json.dumps({"__error__": "unavailable"}))
        raise

    await redis.setex(key, 3600, json.dumps(result))
    return result
```

**Use a different sentinel format (avoid collisions with valid responses):**

```python
# Wrap responses in a discriminated union for clarity
import json

def serialize_cache(value: dict | None) -> str:
    if value is None:
        return json.dumps({"_cached": "not_found"})
    return json.dumps({"_cached": "ok", "value": value})

def deserialize_cache(raw: bytes | str) -> tuple[bool, dict | None]:
    """Returns (is_hit, value). value is None for cached negatives."""
    parsed = json.loads(raw)
    if parsed["_cached"] == "not_found":
        return True, None
    return True, parsed["value"]
```

**Negative cache abuse — limit the cardinality:**

A scraper trying random product IDs can fill Redis with millions of NOT_FOUND entries. Set a reasonable TTL on negatives and consider a Bloom filter for definitive "doesn't exist" checks:

```python
import pybloom_live

# Bloom filter of all valid product IDs (rebuilt periodically)
_product_id_bloom: pybloom_live.BloomFilter | None = None

async def is_valid_product_id(product_id: str) -> bool:
    if _product_id_bloom is None:
        return True  # bloom not loaded — proceed to actual lookup
    if product_id not in _product_id_bloom:
        return False  # definitely doesn't exist — skip cache and origin entirely
    return True  # might exist — proceed
```

**Don't cache server errors (5xx) as negatives:**

5xx is a transient signal — the origin might recover. Caching it as a negative makes a recovery invisible for the TTL. Use circuit breakers ([[protect-circuit-breaker-per-downstream]]) for 5xx handling instead.

**Symptom of missing negative cache:**
- Origin traffic dominated by 404s
- "404 logs are 30% of all log volume"
- Scraper traffic ignored by aggregate metrics but burning origin cycles

Reference: [Memcached — Negative caching](https://github.com/memcached/memcached/wiki/Programming#caching-negative-results) | [AWS — Caching strategies](https://aws.amazon.com/builders-library/caching-challenges-and-strategies/)
