---
title: Surface Partiality in the Response Envelope
impact: HIGH
impactDescription: prevents callers caching degraded responses as complete
tags: resilience, partial, envelope, response, observability
---

## Surface Partiality in the Response Envelope

When one of three recommenders fails and you return blended results from the two that succeeded, the response is *technically* successful — HTTP 200 — but it's degraded. If the response shape doesn't signal that, downstream callers (CDN, mobile app, frontend cache) treat it as a complete success and may cache it for hours. Now your degraded response is cached widely *after* the failing recommender has recovered.

The envelope: a discriminated response shape with `partial: bool`, `sources_used: list[str]`, `failed_sources: list[str]`, and per-source status info. Callers see partiality at-a-glance and can decide whether to cache, retry, or surface to the user.

**Incorrect (no signal — degraded indistinguishable from complete):**

```python
async def recommendations_view(request):
    results = await asyncio.gather(
        personalize_client.get(request.user.id),
        affinity_client.get(request.user.id),
        databricks_client.invoke(request.user.id),
        return_exceptions=True,
    )
    successful = [r for r in results if not isinstance(r, BaseException)]
    items = blend(successful)
    return JsonResponse({"items": items})
# CDN caches this. Mobile app caches this. Both think it's a full response.
```

**Correct (envelope flags partiality):**

```python
async def recommendations_view(request):
    SOURCES = ["personalize", "affinity", "databricks"]
    raw_results = await asyncio.gather(
        personalize_client.get(request.user.id),
        affinity_client.get(request.user.id),
        databricks_client.invoke(request.user.id),
        return_exceptions=True,
    )

    sources_used = []
    failed_sources = []
    by_source: dict[str, list[dict]] = {}

    for name, result in zip(SOURCES, raw_results):
        if isinstance(result, BaseException):
            failed_sources.append({
                "source": name,
                "error_class": type(result).__name__,
                "message": str(result)[:120],
            })
            logger.warning("recommender_failed", source=name, error=str(result))
        else:
            sources_used.append(name)
            by_source[name] = result

    items = blend(by_source)
    partial = bool(failed_sources)

    response = {
        "items": items,
        "partial": partial,
        "sources_used": sources_used,
        "failed_sources": failed_sources,
        "model_version": settings.RECOMMENDER_MODEL_VERSION,
    }
    http_status = 200
    if not sources_used:
        # ALL sources failed — degrade further (see [[resilience-default-ranking-fallback]])
        response["items"] = await fallback_ranking(request.user.id)
        response["sources_used"] = ["fallback"]
    return JsonResponse(response, status=http_status)
```

**Set Cache-Control to reflect partiality:**

```python
def make_cache_control(partial: bool) -> str:
    if partial:
        return "private, max-age=30, stale-while-revalidate=60"  # short TTL
    return "private, max-age=300, stale-while-revalidate=600"  # full TTL

response = JsonResponse(response_body)
response["Cache-Control"] = make_cache_control(partial=response_body["partial"])
return response
```

CDNs/proxies honoring `Cache-Control` will cache partial responses briefly (don't pin staleness for hours) and complete responses longer.

**For multiple consumers, expose per-source health:**

```python
# Richer envelope — clients can decide which sections to render
{
    "items": [...],
    "partial": True,
    "sources": [
        {"name": "personalize", "status": "ok",      "item_count": 12},
        {"name": "affinity",    "status": "ok",      "item_count": 8},
        {"name": "databricks",  "status": "failed",  "error": "circuit_open"},
    ],
    "fallback_applied": False,
    "model_version": "v23",
    "generated_at": "2026-05-19T14:30:00Z",
}
```

**Discriminate at the HTTP layer too (for old clients that ignore the body):**

```python
response["X-Recommender-Partial"] = "true" if partial else "false"
response["X-Recommender-Sources"] = ",".join(sources_used)
# Server logs include these; observability dashboards filter by them
```

**Don't return 503 when partial results are useful:**

```python
# ❌ Triggers retry logic in clients, makes the situation worse
if failed_sources:
    return JsonResponse({"error": "degraded"}, status=503)

# ✅ 200 with partial flag — clients render what they got
return JsonResponse({"items": items, "partial": True, ...}, status=200)
```

**When to return 503 instead:**

- ALL sources failed AND no fallback is reasonable
- Critical-path data missing (cart, account info — not a degradable surface)
- You explicitly want clients to retry (use 503 + Retry-After)

**Frontend rendering of partial responses:**

The frontend can show a subtle indicator ("Updated recommendations may be limited") without alarming the user. The signal in the envelope makes this possible.

**Observability — track partial-response rate:**

```python
metrics.histogram("recommendations.sources_used_count", value=len(sources_used))
metrics.increment("recommendations.partial", value=1 if partial else 0)
metrics.increment("recommendations.fallback_applied", value=1 if not sources_used else 0)
# Production target: partial < 5%, fallback < 1%
```

**Symptom of missing partial envelope:**
- "Recommendations sometimes look weird but we don't know when" — silent partiality
- CDN caches degraded responses; users see them long after recovery
- Frontend can't differentiate "ML inference is down" from "user has no recommendations"

Reference: [Vercel — Partial pre-rendering](https://vercel.com/docs/incremental-static-regeneration) | [RFC 7234 — Cache-Control](https://datatracker.ietf.org/doc/html/rfc7234)
