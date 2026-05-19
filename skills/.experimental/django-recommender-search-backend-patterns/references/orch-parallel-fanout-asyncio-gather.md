---
title: Fan Out to Recommenders with asyncio.gather
impact: CRITICAL
impactDescription: reduces N sequential downstream calls to 1 round-trip time
tags: orch, asyncio, gather, fanout, parallelism
---

## Fan Out to Recommenders with asyncio.gather

A recommendation endpoint that calls Personalize (180ms p95), the user-affinity microservice (120ms), and a Databricks ML endpoint (220ms) sequentially serves at ~520ms p95. The same calls in parallel serve at ~220ms p95 — bound by the slowest downstream, not the sum. The bottleneck moves from your code to the network/service that's actually slow, which is the only one you can optimize.

`asyncio.gather` is the standard way to start independent coroutines in parallel. The trap: writing `await` for each call in sequence cancels every parallelism benefit even when the calls are coroutines.

**Incorrect (sequential awaits — 3× slower than necessary):**

```python
# views.py
async def recommendations_view(request):
    user_id = request.user.id

    personalize = await personalize_client.get_recommendations(user_id)   # 180ms
    affinity    = await affinity_client.get_scored_items(user_id)          # 120ms (waits for personalize)
    databricks  = await databricks_client.invoke_ranker(user_id, items=[]) # 220ms (waits for affinity)
    # Total: 520ms — and the user just sees a slow page.

    blended = blend_results([personalize, affinity, databricks])
    return JsonResponse(blended)
```

**Correct (parallel via asyncio.gather):**

```python
import asyncio

async def recommendations_view(request):
    user_id = request.user.id

    personalize, affinity, databricks = await asyncio.gather(
        personalize_client.get_recommendations(user_id),
        affinity_client.get_scored_items(user_id),
        databricks_client.invoke_ranker(user_id, items=[]),
    )
    # Total: ~220ms — bound by the slowest call only.

    blended = blend_results([personalize, affinity, databricks])
    return JsonResponse(blended)
```

**When fan-out has dependencies (one call needs another's result):**

```python
async def recommendations_view(request):
    user_id = request.user.id

    # Step 1: fetch user segment (needed for personalize call)
    segment = await segment_client.get(user_id)

    # Step 2: the three actually-independent calls in parallel
    personalize, affinity, databricks = await asyncio.gather(
        personalize_client.get_recommendations(user_id, segment=segment),
        affinity_client.get_scored_items(user_id),
        databricks_client.invoke_ranker(user_id, segment=segment, items=[]),
    )
    return JsonResponse(blend_results([personalize, affinity, databricks]))
```

**Don't use `asyncio.gather` for unrelated background work:** when you don't need the result before responding (analytics events, cache warming), fire-and-forget with `asyncio.create_task` and let it run after the response is sent. `gather` waits — `create_task` doesn't.

**Pair with [[orch-return-exceptions-on-fanout]]:** by default, one failure in `gather` cancels the other tasks. For partial-results behavior, pass `return_exceptions=True`.

**Pair with [[orch-propagate-request-deadline]]:** parallelism doesn't help if one downstream hangs — set a deadline on each call.

Reference: [Python — asyncio.gather](https://docs.python.org/3/library/asyncio-task.html#asyncio.gather) | [Django — Async views](https://docs.djangoproject.com/en/5.0/topics/async/)
