---
title: Separate Anonymous and Personalized Code Paths
impact: MEDIUM-HIGH
impactDescription: prevents 60-80% of traffic hitting expensive personalization
tags: blend, anonymous, personalized, cost, cache
---

## Separate Anonymous and Personalized Code Paths

For most consumer APIs, anonymous (logged-out) traffic is 60-80% of requests. Calling Personalize/Databricks for every anonymous request burns inference cost on requests where personalization is impossible (no user history, no user ID). Worse, the responses can't be cached effectively — there's no `user_id` to scope by, so anonymous traffic either all gets the same Personalize response (wasteful) or skips caching (expensive).

Split the code paths cleanly: anonymous traffic gets a heavily cached "segment-based popular" response; logged-in traffic gets personalized blending. Both can share the same response shape so the frontend doesn't have to care.

**Incorrect (one path for all — personalization called for anon traffic):**

```python
async def recommendations_view(request):
    user_id = request.user.id if request.user.is_authenticated else "anon"
    # Personalize gets called even for anonymous users — wasted inference
    items = await personalize_client.get_recommendations(user_id)
    return JsonResponse({"items": items})
```

**Correct (branch early; anonymous path is cheap and cacheable):**

```python
async def recommendations_view(request):
    if not request.user.is_authenticated:
        return await _anonymous_recommendations(request)
    return await _personalized_recommendations(request)

async def _anonymous_recommendations(request):
    """Anonymous path — no user ID, but we have some signal."""
    segment = _infer_segment_from_request(request)  # geo, device, referrer, A/B bucket
    items = await get_popular_items(segment=segment)   # cached aggressively (~1h TTL)
    return JsonResponse({
        "items": items,
        "personalized": False,
        "segment": segment,
    })

async def _personalized_recommendations(request):
    """Logged-in path — full fan-out + blending."""
    user_id = request.user.id
    results = await asyncio.gather(
        personalize_client.get_recommendations(user_id),
        affinity_client.get_scored_items(user_id),
        databricks_client.invoke_ranker(user_id, items=[]),
        return_exceptions=True,
    )
    items = blend_with_fallback(results, user_id)
    return JsonResponse({
        "items": items,
        "personalized": True,
    })
```

**Infer a segment for anonymous traffic to add some signal:**

```python
def _infer_segment_from_request(request) -> str:
    """Best-effort segment from request signals — never personal."""
    geo = request.headers.get("CloudFront-Viewer-Country", "XX")
    device = "mobile" if "Mobi" in request.headers.get("User-Agent", "") else "desktop"
    referrer = request.META.get("HTTP_REFERER", "")
    if "instagram.com" in referrer:
        traffic_source = "social"
    elif "google.com" in referrer:
        traffic_source = "search"
    else:
        traffic_source = "direct"
    return f"{geo}:{device}:{traffic_source}"
    # → "US:mobile:social", "DE:desktop:search", etc.
    # ~50-200 distinct segments. Each cacheable.
```

**Caching characteristics by path:**

| Path | Cache key | TTL | Cache hit rate |
|------|-----------|-----|----------------|
| Anonymous | `popular:{segment}` | 1h | 95-99% (same response for many users) |
| Personalized | `recs:user:{user_id}:v{model_version}` | 5-15min | 30-60% (per-user) |

Anonymous traffic essentially free (one segment computation per hour); personalized traffic does the expensive work only for users who actually have personalization signals.

**Pre-warm popular segments:**

```python
# Periodic task — runs every 30 minutes
async def warm_popular_caches():
    top_segments = await get_top_segments_by_traffic()  # ["US:mobile:social", "US:desktop:direct", ...]
    await asyncio.gather(
        *(get_popular_items(segment=s) for s in top_segments[:20])
    )
# After this runs, anonymous traffic to top segments hits cache 100% of the time.
```

**Don't accidentally personalize anonymous traffic:**

```python
# ❌ Some libraries treat None or empty string as a special user
items = await personalize_client.get_recommendations(user_id="")
# Personalize may interpret "" as a different "user" — wasted call, garbage results
```

**Use a different model for anonymous if Personalize supports it:**

AWS Personalize has separate "user-personalization" and "popularity-count" recipes — use the latter for anonymous traffic if you need ML-driven popularity (it accounts for time-of-day, recency, segment).

**For logged-in users, *still* fall back to anonymous path when the user is in cold-start:**

```python
async def _personalized_recommendations(request):
    user_state = await get_user_state(request.user.id)
    if user_state.is_cold:  # see [[blend-cold-start-fallback]]
        return await _anonymous_recommendations(request)  # reuse the cheap path
    # ... full personalization
```

**Response shape parity:**

Keep the response shape identical across paths so the API client doesn't branch:

```python
# Both paths return:
{
    "items": [...],
    "personalized": bool,         # ← signals which strategy was used
    "segment": str | None,        # ← anonymous-only signal
    "model_version": str | None,  # ← personalized-only signal (for cache versioning)
}
```

**Symptom of missing anonymous split:**
- Personalize / Databricks inference bills disproportionate to logged-in traffic
- Anonymous traffic has poor cache hit rate
- Latency for anonymous users matches personalized users (it should be much lower)

Reference: [AWS Personalize — Recipes](https://docs.aws.amazon.com/personalize/latest/dg/working-with-predefined-recipes.html)
