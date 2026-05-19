---
title: Use return_exceptions=True for Partial-Results Fan-out
impact: CRITICAL
impactDescription: prevents one downstream failure from failing the whole request
tags: orch, asyncio, gather, partial-results, fanout
---

## Use return_exceptions=True for Partial-Results Fan-out

`asyncio.gather` by default raises on the first task that raises — and crucially, it does NOT cancel the other in-flight tasks. The exception propagates, but the other coroutines silently run to completion in the background while your view returns a 500. The user sees an error because of *one* downstream blip; the other two recommenders succeeded and their results are now in the garbage collector.

`return_exceptions=True` flips this: each task either returns its result or returns its exception object. Your code inspects results, builds a partial response with whatever succeeded, and the user sees a degraded-but-useful page.

**Incorrect (one downstream failure → entire request fails):**

```python
async def recommendations_view(request):
    user_id = request.user.id
    try:
        personalize, affinity, databricks = await asyncio.gather(
            personalize_client.get_recommendations(user_id),
            affinity_client.get_scored_items(user_id),
            databricks_client.invoke_ranker(user_id, items=[]),
        )
    except DatabricksError:
        # ❌ Personalize + affinity succeeded but we throw their results away
        return JsonResponse({"error": "recommendations unavailable"}, status=503)
    return JsonResponse(blend_results([personalize, affinity, databricks]))
```

**Correct (partial-results path with exception inspection):**

```python
async def recommendations_view(request):
    user_id = request.user.id

    results = await asyncio.gather(
        personalize_client.get_recommendations(user_id),
        affinity_client.get_scored_items(user_id),
        databricks_client.invoke_ranker(user_id, items=[]),
        return_exceptions=True,  # ← results may include Exception instances
    )

    sources = {"personalize": results[0], "affinity": results[1], "databricks": results[2]}
    successful = {
        name: items for name, items in sources.items() if not isinstance(items, BaseException)
    }
    failed = {name: type(err).__name__ for name, err in sources.items()
              if isinstance(err, BaseException)}

    # Log failures with structured tags — silence on the response, not in metrics
    for name, err in sources.items():
        if isinstance(err, BaseException):
            logger.warning("recommender_failed", source=name, error=str(err))

    blended = blend_results(list(successful.values()))
    return JsonResponse({
        "items": blended,
        "sources_used": list(successful.keys()),
        "partial": bool(failed),                  # ← caller can see this was degraded
        "failed_sources": list(failed.keys()),
    })
```

**Define a fallback when ALL sources fail:**

```python
if not successful:
    # Everything failed — return a stable default (e.g., editorial list, popular items)
    fallback = await default_ranking_client.get_popular(limit=20)
    return JsonResponse({
        "items": fallback, "partial": True,
        "sources_used": ["fallback"], "failed_sources": list(failed.keys()),
    })
```

**Warning (exception types aren't only `Exception`):** `return_exceptions=True` also captures `CancelledError` — useful for diagnosing timeout cancellations from [[orch-propagate-request-deadline]]. Treat `CancelledError` as a timeout, not a downstream error.

**Pair with [[resilience-partial-response-envelope]]:** the response shape must signal partiality clearly so callers don't cache a degraded response as if it were complete.

Reference: [Python — asyncio.gather return_exceptions](https://docs.python.org/3/library/asyncio-task.html#asyncio.gather)
