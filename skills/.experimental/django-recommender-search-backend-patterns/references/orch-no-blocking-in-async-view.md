---
title: Never Block the Event Loop in Async Views
impact: CRITICAL
impactDescription: prevents 1 slow request from blocking all other requests
tags: orch, async, blocking, event-loop, throughput
---

## Never Block the Event Loop in Async Views

A single synchronous ORM call, `time.sleep`, `requests.get`, or sync boto3 call inside an `async def` view blocks the event loop for the duration of the call. While it's blocked, the worker cannot process *any* other request. With uvicorn at typical 1-2 workers and async concurrency of hundreds of in-flight requests, one 200ms blocking call drops effective throughput from 500 RPS to 5 RPS until the call returns.

This rule is the prohibition. For *how* to wrap sync code correctly (Django async ORM, `sync_to_async` semantics, boto3 in async views, connection-pool sizing for ASGI), see [[async-sync-to-async-orm]].

**Incorrect (sync ORM in async view — blocks the loop):**

```python
async def recommendations_view(request):
    # ❌ Sync ORM call inside an async view
    user_profile = UserProfile.objects.get(user=request.user)
    # While this query runs, NO other request can proceed on this worker.
    personalize = await personalize_client.get(request.user.id,
                                                segment=user_profile.segment)
    return JsonResponse(personalize)
```

**Correct (use the async ORM or sync_to_async):**

```python
async def recommendations_view(request):
    # ✅ Native async ORM (Django 4.1+) — see [[async-sync-to-async-orm]] for full table
    user_profile = await UserProfile.objects.aget(user=request.user)
    personalize = await personalize_client.get(request.user.id,
                                                segment=user_profile.segment)
    return JsonResponse(personalize)
```

**Common blocking sources to watch for:**

| Sync call (blocks loop) | Replace with |
|------------------------|--------------|
| `Model.objects.get/filter/create/...` | `aget`/`afilter`/`acreate` (see [[async-sync-to-async-orm]]) |
| `time.sleep(N)` | `await asyncio.sleep(N)` |
| `requests.get(url)` | `await httpx_client.get(url)` |
| `boto3_client.call(...)` | `await asyncio.to_thread(boto3_client.call, ...)` |
| `subprocess.run(...)` | `await asyncio.create_subprocess_exec(...)` |
| Heavy `numpy`/`PIL`/`cv2` ops | `await asyncio.to_thread(fn, ...)` (CPU-bound but at least frees the loop) |
| Synchronous Redis client (`redis.Redis`) | `redis.asyncio.Redis` |
| Synchronous OpenSearch client | `await asyncio.to_thread(opensearch.search, ...)` or `opensearch-py-async` |

**Diagnosing a blocked loop:**

In production, the symptom is "all requests get slow simultaneously even though only one downstream is degraded" — that's the queue building up behind the blocked loop. Tools:

- `aiomonitor` / `aiodebug.log_slow_callbacks` — log when the loop is blocked >100ms
- `asyncio.get_event_loop().slow_callback_duration = 0.1` then enable debug mode

**When to use a sync view instead of fighting async:**

If the entire view is sync-heavy (multiple sync ORM calls, no fan-out, no `await`-able IO), a sync Django view with gunicorn's threaded worker model is simpler than smearing `sync_to_async` everywhere. Async views earn their complexity when there's IO fan-out worth parallelizing.

**Symptom checklist:**
- "Async view throughput same as sync" — likely blocking somewhere
- p99 spikes correlated with database query latency, not downstream fan-out
- Connection pool exhausted under load
- One slow query causes "all requests slow" rather than just that one user

Reference: [Django — Async support](https://docs.djangoproject.com/en/5.0/topics/async/) | [Real Python — Async views in Django](https://realpython.com/django-async-views/)
