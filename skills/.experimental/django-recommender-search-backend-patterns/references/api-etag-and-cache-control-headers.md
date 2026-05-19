---
title: Set ETag and Cache-Control for CDN/Client Reuse
impact: MEDIUM
impactDescription: enables 304 Not Modified responses and CDN caching
tags: api, etag, cache-control, headers, cdn
---

## Set ETag and Cache-Control for CDN/Client Reuse

A response without `Cache-Control` headers can't be cached by CDNs or browsers — every request hits Django. A response with `ETag` lets clients re-validate (sending `If-None-Match`) and get a 304 Not Modified (no body) instead of the full response. For an API serving largely-stable data (popular feeds, search-result snapshots), these headers cut Django load to <10% of the otherwise-needed capacity.

The trick is correctness: don't set long TTLs on per-user data, don't cache partial responses ([[resilience-partial-response-envelope]]) as long as fresh ones, and use the `Vary` header to prevent cross-segment serving.

**Incorrect (no caching headers — every request hits Django):**

```python
def popular_view(request):
    items = get_popular_items()
    return JsonResponse({"items": items})
# CDN: can't cache, sends every request to origin
# Browser: must re-fetch every page load
```

**Correct (ETag + Cache-Control + Vary):**

```python
import hashlib
import json

def popular_view(request):
    items = get_popular_items(segment=_segment(request))

    body = {"items": items, "generated_at": ...}
    body_bytes = json.dumps(body, sort_keys=True).encode()

    etag = '"' + hashlib.blake2b(body_bytes, digest_size=8).hexdigest() + '"'

    # Conditional GET — if the client sent If-None-Match, compare
    if request.META.get("HTTP_IF_NONE_MATCH") == etag:
        return HttpResponse(status=304)  # no body needed; client uses its cache

    response = HttpResponse(body_bytes, content_type="application/json", status=200)
    response["ETag"] = etag
    response["Cache-Control"] = "public, max-age=60, stale-while-revalidate=300"
    response["Vary"] = "Accept-Language, Authorization"
    return response
```

**Cache-Control directives (composition matters):**

| Directive | Effect |
|-----------|--------|
| `public` | CDN can cache |
| `private` | Only the user's browser caches; CDN can't |
| `max-age=N` | Fresh for N seconds |
| `s-maxage=N` | Fresh for N seconds *for shared caches (CDN)*; overrides max-age for them |
| `stale-while-revalidate=N` | Serve stale up to N seconds while revalidating in background |
| `stale-if-error=N` | Serve stale up to N seconds if origin returns 5xx |
| `no-cache` | Must revalidate before reuse (still cacheable!) |
| `no-store` | Never cache anywhere — for sensitive data |
| `must-revalidate` | Don't serve stale; revalidate when expired |
| `immutable` | Content will never change at this URL (good for versioned assets) |

**Common combinations:**

| Endpoint type | Cache-Control |
|---------------|---------------|
| Anonymous popular feed | `public, max-age=60, s-maxage=300, stale-while-revalidate=600` |
| Logged-in personalized | `private, max-age=30, stale-while-revalidate=120` |
| Versioned static asset (image, JS) | `public, max-age=31536000, immutable` |
| Sensitive (account, billing) | `private, no-cache, no-store, must-revalidate` |
| Partial response | `private, max-age=30, stale-while-revalidate=60` (short TTL) |

**Vary header — prevent cross-context serving:**

The Vary header tells CDNs which request headers affect the response. Without it, CDN may return the English response to an Italian user, or an authenticated response to an anonymous user:

```python
response["Vary"] = "Accept-Language, Authorization, X-Tenant-Id"
```

Common Vary values:

- `Accept-Language` — localized responses
- `Authorization` — anonymous vs authenticated
- `Cookie` — when cookies affect the response (be careful: cache miss rate explodes)
- `Accept-Encoding` — for compressed responses (most servers add this automatically)
- `X-*-Id` — for tenant or segment headers

**Don't include `Cookie` in Vary unless necessary:**

`Vary: Cookie` means every distinct cookie value gets its own cache entry. Since cookies are typically per-user, this defeats CDN caching entirely. If only certain cookies affect the response, use a more specific header (e.g., a `X-User-Segment` header set by your edge logic).

**Generate ETags from content hash, not random:**

```python
# Hash the response body (deterministic)
etag = '"' + hashlib.blake2b(body_bytes, digest_size=8).hexdigest() + '"'

# Or from a version + timestamp
etag = f'"v23-{int(updated_at.timestamp())}"'

# Or weak ETag (less strict comparison)
etag = f'W/"abc123"'  # weak — semantic equivalence, not byte-for-byte
```

**Cache the ETag itself for expensive computations:**

```python
async def search_view(request):
    cache_key = f"search:{hash(request.GET['q'])}:etag"
    cached_etag = await redis.get(cache_key)

    if cached_etag and request.META.get("HTTP_IF_NONE_MATCH") == cached_etag.decode():
        return HttpResponse(status=304)

    items = await opensearch_search(request.GET["q"])
    body = {"items": items}
    body_bytes = json.dumps(body, sort_keys=True).encode()
    etag = '"' + hashlib.blake2b(body_bytes, digest_size=8).hexdigest() + '"'

    await redis.setex(cache_key, 300, etag)

    response = HttpResponse(body_bytes, status=200)
    response["ETag"] = etag
    response["Cache-Control"] = "public, max-age=60, stale-while-revalidate=300"
    return response
```

**Don't cache responses with auth-dependent data without `Vary: Authorization`:**

```python
# ❌ CDN may serve User A's account data to User B
response["Cache-Control"] = "public, max-age=300"
# (no Vary)

# ✅ Either private OR vary by auth
response["Cache-Control"] = "private, max-age=300"   # user-only cache
# or
response["Cache-Control"] = "public, max-age=300"
response["Vary"] = "Authorization"                    # CDN keys by auth header
```

**Use 304 to save bandwidth, not 200 with same body:**

```python
# ❌ Sending the same response with same ETag every time wastes bandwidth
# ✅ Return 304 when If-None-Match matches
if request.META.get("HTTP_IF_NONE_MATCH") == etag:
    return HttpResponse(status=304)  # no body — client uses its cached copy
```

**Symptom of missing cache headers:**
- "Why is the API hit so much for popular endpoints?" — no CDN cacheability
- CDN hit ratio < 30% on cacheable endpoints
- Mobile users complain about data usage for repeated visits

Reference: [MDN — Cache-Control](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control) | [MDN — ETag](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag) | [Django — HTTP shortcut decorators](https://docs.djangoproject.com/en/5.0/topics/http/decorators/)
