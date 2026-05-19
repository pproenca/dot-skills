---
title: Define a Default Ranking for Total ML Outage
impact: HIGH
impactDescription: prevents empty recommendations when all sources fail
tags: resilience, fallback, default-ranking, popular
---

## Define a Default Ranking for Total ML Outage

When Personalize is down AND the affinity service is down AND Databricks is down — rare but it happens (regional AWS outage, internal deploy across multiple services) — every recommender call fails. Without a deeper fallback, the recommendation endpoint returns empty results or 503 to every user. Define a *default ranking* that has zero ML dependency: hand-curated editorial picks, popularity from precomputed nightly batch, or trending from a cached data warehouse export.

The default ranking lives in Redis, refreshed every few hours by a background job. The runtime path doesn't depend on any service that can fail. When all ML sources are down, the API still returns something useful.

**Incorrect (no deeper fallback — total outage = empty response):**

```python
async def get_recommendations(user_id: str):
    results = await asyncio.gather(
        personalize_client.get(user_id),
        affinity_client.get(user_id),
        databricks_client.invoke(user_id),
        return_exceptions=True,
    )
    successful = {n: r for n, r in zip(SOURCES, results) if not isinstance(r, BaseException)}
    if not successful:
        return JsonResponse({"items": []})  # ❌ empty page for the user
    return JsonResponse({"items": blend(successful)})
```

**Correct (default ranking as final fallback):**

```python
async def get_recommendations(request):
    user_id = request.user.id if request.user.is_authenticated else None

    # Try ML sources
    results = await asyncio.gather(
        personalize_client.get(user_id) if user_id else asyncio.sleep(0),
        affinity_client.get(user_id) if user_id else asyncio.sleep(0),
        databricks_client.invoke(user_id) if user_id else asyncio.sleep(0),
        return_exceptions=True,
    )
    successful = {n: r for n, r in zip(SOURCES, results)
                  if not isinstance(r, BaseException) and isinstance(r, list)}

    if successful:
        items = blend(successful)
        return JsonResponse({
            "items": items,
            "source": "ml_blended",
            "personalized": True,
        })

    # ML all failed — use the default ranking
    segment = _infer_segment(request, user=request.user)
    default_items = await get_default_ranking(segment=segment)
    return JsonResponse({
        "items": default_items,
        "source": "default_ranking",
        "personalized": False,
        "degraded": True,                # ← inform clients
    })

async def get_default_ranking(segment: str) -> list[dict]:
    """Default ranking has ZERO ML dependency. Pre-computed and cached."""
    cached = await redis.get(f"default_ranking:{segment}")
    if cached:
        return json.loads(cached)

    # Origin: read from a precomputed table in the warehouse / S3 / static config
    # This origin is itself static and never fails (or has its own resilience)
    items = await load_precomputed_ranking(segment=segment)
    await redis.setex(f"default_ranking:{segment}", 24 * 3600, json.dumps(items))
    return items
```

**Background job that maintains the default ranking:**

```python
# Runs nightly via Celery/Airflow/Lambda — populates Redis with precomputed rankings
async def refresh_default_rankings():
    segments = ["US:mobile", "US:desktop", "EU:mobile", "EU:desktop", "default"]
    for segment in segments:
        try:
            # Source: warehouse query of last-7-days popularity, filtered by segment
            items = await warehouse_query(
                """
                SELECT product_id, ARRAY_AGG(STRUCT(title, thumbnail, price)) AS detail,
                       COUNT(*) AS views
                FROM analytics.product_views
                WHERE event_date > CURRENT_DATE - INTERVAL '7 days'
                  AND segment = @segment
                GROUP BY product_id
                ORDER BY views DESC
                LIMIT 200
                """,
                params={"segment": segment},
            )
            await redis.setex(
                f"default_ranking:{segment}",
                36 * 3600,  # 36h TTL — refresh wave runs every 24h with safety margin
                json.dumps(items),
            )
            logger.info("refreshed_default_ranking", segment=segment, count=len(items))
        except Exception as e:
            logger.error("default_ranking_refresh_failed", segment=segment, error=str(e))
            # Don't raise — continue with other segments. The existing value stays valid.
```

**The fallback's fallback (Redis itself is down):**

```python
# Bundle a static fallback in the Django app — the floor of the resilience chain
HARDCODED_FALLBACK_IDS = [
    # Top 20 universally-popular items — embedded in code, no I/O
    "prod-001", "prod-002", "prod-003", ...,
]

async def get_default_ranking(segment: str) -> list[dict]:
    try:
        cached = await redis.get(f"default_ranking:{segment}")
        if cached:
            return json.loads(cached)
    except RedisError:
        pass  # Redis down — fall through

    # Try warehouse (slow but reliable-ish)
    try:
        return await load_precomputed_ranking(segment=segment)
    except Exception:
        pass

    # Last resort: static list bundled with the app
    return await load_static_items_by_ids(HARDCODED_FALLBACK_IDS)
```

**Why "default" ranking matters even when partial blends work:**

Even when partial blends work (1-2 sources succeeded), the default ranking is your floor. If a deploy or config bug causes blending to misbehave, the default ranking is the contract you can always meet. Surface this to oncall: "when in doubt, render the default ranking."

**Differentiate "degraded" from "personalized" in the response:**

The frontend can render a subtle "Popular items" header on the degraded path so users understand why their personal recommendations look different. The signal in the envelope (`personalized: false`, `degraded: true`) enables this.

**Test the default ranking path regularly:**

Add an integration test that simulates total ML failure (all clients raise) and asserts that:
- The endpoint returns 200
- Items are non-empty
- The `degraded` flag is set
- The `source` is `"default_ranking"`

This is the test that fails *exactly* when you need the fallback and it isn't wired.

**Symptom of missing default ranking:**
- "When Personalize is down, the homepage is empty"
- Recommendation outages cascade to other features (people who click recommendations also click add-to-cart, etc.)
- Engineers can't sleep through regional AWS outages

Reference: [Netflix — Chaos engineering](https://netflixtechblog.com/the-netflix-simian-army-16e57fbab116) | [Site Reliability Engineering — Graceful degradation](https://sre.google/sre-book/handling-overload/)
