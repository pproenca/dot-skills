---
title: Isolate Cache Keys by Segment and Auth State
impact: HIGH
impactDescription: prevents cross-segment data leakage in cached responses
tags: cache, segmentation, isolation, security, keys
---

## Isolate Cache Keys by Segment and Auth State

A cache key of `recs:popular` returned to logged-in user A: fine. The same key served to admin user B who should see internal-only items: privacy leak. The same key served to user C in a region where item X is restricted: legal issue. Caching a response means trusting that any future request with the same key should see the same data — so the key MUST include every dimension that can affect what the user is authorized or expected to see.

Common dimensions that need to be in the key: auth state (anon vs logged-in), user role/tier, locale, region, segment, feature flags affecting filtering, A/B bucket.

**Incorrect (single global key — same response served across all contexts):**

```python
async def get_popular():
    cached = await redis.get("popular")  # ❌ one key for everyone
    if cached:
        return json.loads(cached)
    items = await fetch_popular_from_origin()
    await redis.setex("popular", 3600, json.dumps(items))
    return items
# Admin sees same as regular user. EU user sees US-only items. Banned user sees blocked content.
```

**Correct (key includes every authorization-relevant dimension):**

```python
async def get_popular(*, user, request):
    # Build a key that captures everything that influences the response
    key_parts = [
        "popular",
        # Auth dimension — anon vs logged-in users get different data
        "anon" if not user.is_authenticated else f"u:{user.id}",
        # Locale / region — content varies by jurisdiction
        request.locale,                 # "en-US", "de-DE"
        request.headers.get("CloudFront-Viewer-Country", "XX"),
        # Role / tier — internal items only for staff
        user.role if user.is_authenticated else "anon",
        # A/B bucket — different variants of the response per test
        request.ab_bucket("popular_layout") or "control",
    ]
    key = ":".join(key_parts)
    cached = await redis.get(key)
    if cached:
        return json.loads(cached)
    items = await fetch_popular_from_origin(
        locale=request.locale,
        country=key_parts[3],
        role=key_parts[4],
        ab_bucket=key_parts[5],
    )
    await redis.setex(key, 3600, json.dumps(items))
    return items
```

**Don't cache per-user when segment-keyed cache works:**

For an anonymous-traffic endpoint, the user's individual identity doesn't influence the response (they're anonymous!) — but the segment does. Cache by segment, not by user:

```python
# ❌ Per-user cache for anonymous traffic — pointless, never hits
key = f"popular:anon:{anonymous_session_id}:US:en-US"  # one key per session

# ✅ Segment cache — many anonymous users share cached entries
key = f"popular:anon:US:en-US:mobile"  # ~50 distinct keys total
```

**Tier permissions explicitly:**

```python
def cache_key_for_search(user, query: str) -> str:
    """Search results vary by what the user is authorized to see."""
    if not user.is_authenticated:
        # Anonymous: only public items
        return f"search:public:{hash(query)}:{user.locale}"
    if user.role == "admin":
        # Admin sees internal items too — different key namespace
        return f"search:admin:{user.id}:{hash(query)}"
    return f"search:user:{user.tier}:{hash(query)}:{user.locale}"
```

**Hash long key components to keep keys short:**

```python
import hashlib

def hash_query(query: str) -> str:
    """Short, stable hash of long inputs (e.g., complex search filters)."""
    return hashlib.blake2b(query.encode(), digest_size=8).hexdigest()

key = f"search:public:{hash_query(query)}:en-US"
# Result: "search:public:a3f8b2d491c5e7a0:en-US"
```

**Cross-segment dimensions to consider:**

| Dimension | When it matters |
|-----------|-----------------|
| Auth state | Anonymous vs logged-in see different content |
| User role | Admin/staff vs regular user vs trial vs paid |
| Locale | Translations, content availability |
| Country/region | Legal restrictions, currency, shipping |
| Feature flags | A/B tests that change the response shape |
| Tenant ID | Multi-tenant SaaS |
| Filter context | User-applied filters in search/listings |
| Time of day / day | Time-sensitive recommendations |

**Don't put PII directly in keys:**

```python
# ❌ Putting email in the key — leaks if Redis is compromised
key = f"profile:{user.email}"
# ✅ Use opaque user ID
key = f"profile:{user.id}"
```

**Verify isolation with a security test:**

```python
def test_admin_response_not_cached_for_regular_user():
    # Admin makes a request — internal items in response, gets cached
    admin = create_admin()
    response = client.get("/recommendations", user=admin)
    assert "internal_only_item" in response.data["items"]

    # Regular user makes "same" request — must hit different cache entry
    regular = create_regular_user()
    response = client.get("/recommendations", user=regular)
    assert "internal_only_item" NOT in response.data["items"]
```

**Symptom of missing isolation:**
- "User reports seeing data from another account" — most-common cache key collision
- Localized content shows the wrong language briefly after deploy
- A/B test results contaminated (one bucket's response served to the other)

Reference: [Django — Vary header](https://docs.djangoproject.com/en/5.0/topics/cache/#using-vary-headers) | [OWASP — Cache poisoning](https://owasp.org/www-community/attacks/Cache_Poisoning)
