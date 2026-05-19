---
title: Cancel In-Flight Work When the Client Disconnects
impact: MEDIUM
impactDescription: prevents wasted compute on abandoned requests
tags: async, cancellation, disconnect, asgi, resources
---

## Cancel In-Flight Work When the Client Disconnects

A user navigates away mid-request. Their browser closes the connection. The Django worker is still happily calling Personalize + Databricks + OpenSearch + blending — burning ML inference cost, database connections, and downstream rate-limit quota on a response no one will see. Worse, the worker remains busy until everything completes, so the next request waits.

Under ASGI, Django can detect the disconnect and cancel the request. The pattern: check `await request.is_disconnected()` periodically, or rely on `asyncio.CancelledError` propagation. For downstream calls, propagate cancellation so AWS Personalize/Databricks stop processing too (where supported).

**Incorrect (no disconnect detection — work continues after client gone):**

```python
async def recommendations_view(request):
    # User closes browser after 100ms. The view doesn't know.
    user_id = request.user.id
    personalize, affinity, databricks = await asyncio.gather(
        personalize_client.get(user_id),    # still running
        affinity_client.get(user_id),       # still running
        databricks_client.invoke(user_id),  # still running
    )
    items = blend_results([personalize, affinity, databricks])
    return JsonResponse(items)
    # Worker holds resources for the full duration. Wasted.
```

**Correct (check disconnect; propagate cancellation):**

```python
async def recommendations_view(request):
    user_id = request.user.id

    # Wrap the fan-out so we can race it against disconnect detection
    work_task = asyncio.create_task(_fanout_and_blend(user_id))
    disconnect_task = asyncio.create_task(_wait_for_disconnect(request))

    done, pending = await asyncio.wait(
        [work_task, disconnect_task],
        return_when=asyncio.FIRST_COMPLETED,
    )

    if disconnect_task in done:
        # Client gone — cancel the work
        work_task.cancel()
        try:
            await work_task
        except (asyncio.CancelledError, BaseException):
            pass
        # No response needed; the connection is closed
        return HttpResponse(status=499)  # 499 = client closed request (nginx convention)

    # Work completed first — cancel the disconnect watcher
    disconnect_task.cancel()
    items = await work_task
    return JsonResponse({"items": items})

async def _wait_for_disconnect(request):
    while True:
        if await request.is_disconnected():
            return
        await asyncio.sleep(0.1)  # poll every 100ms

async def _fanout_and_blend(user_id: str):
    results = await asyncio.gather(
        personalize_client.get(user_id),
        affinity_client.get(user_id),
        databricks_client.invoke(user_id),
        return_exceptions=True,
    )
    return blend_results(results)
```

**Propagate cancellation to HTTP clients:**

`httpx.AsyncClient` honors `asyncio.CancelledError` — when the parent task is cancelled, in-flight requests are aborted. The downstream server may or may not stop work on disconnect (depends on its own implementation), but at least your worker frees up immediately:

```python
async def _fanout_and_blend(user_id: str):
    # When this task is cancelled, httpx aborts the in-flight requests
    return await asyncio.gather(
        personalize_client.get(user_id),
        databricks_client.invoke(user_id),
        return_exceptions=True,
    )
```

**For boto3 (sync, no async cancellation):**

```python
# boto3 doesn't honor cancellation. asyncio.to_thread propagates cancellation to the
# Python task but the boto3 call continues until completion.
# Best effort: use a short timeout in the boto3 client config so it can't run forever.

import boto3
from botocore.config import Config

_personalize = boto3.client("personalize-runtime", config=Config(
    connect_timeout=1.0,
    read_timeout=2.0,    # caps the worst case
))
```

**Use ASGI lifespan for graceful shutdown:**

```python
# settings/asgi.py
import asyncio
from django.core.asgi import get_asgi_application
from django.conf import settings

django_application = get_asgi_application()

async def application(scope, receive, send):
    if scope["type"] == "lifespan":
        while True:
            message = await receive()
            if message["type"] == "lifespan.startup":
                await send({"type": "lifespan.startup.complete"})
            elif message["type"] == "lifespan.shutdown":
                # Cancel background tasks here
                await _shutdown_background_tasks()
                await send({"type": "lifespan.shutdown.complete"})
                return
    else:
        await django_application(scope, receive, send)
```

**Don't over-engineer for low-stakes endpoints:**

For most recommendation endpoints, the full work is <1s. The user's window for disconnecting is small. Implementing disconnect detection is worth it only when:
- The work is expensive enough to matter (ML inference calls, large query fan-outs)
- p95 latency is high enough that abandonment is common (>500ms)
- You're hitting rate limits or quota constraints

For sub-100ms endpoints, skip the complexity.

**Tradeoff with caching:**

Cancelling a downstream call means the cache won't be populated for the next user. Sometimes you *want* the call to complete even after the original user disconnected, because the next user is about to ask the same thing. For shared-cache endpoints (popular feed, common search), let the request finish:

```python
async def search_view(request):
    if _is_shared_cache_endpoint(request):
        # Don't cancel — let the work warm the cache for others
        return await _search(request)
    # User-specific endpoint — cancel on disconnect
    return await _search_cancellable(request)
```

**Don't cancel partial database writes (data integrity):**

If your view writes to the DB then returns, cancellation between write and response means the data is committed but the user thinks the request failed. They retry, you double-write. Either avoid cancellation for write paths, or use transactions + idempotency keys.

**Symptom of missing cancellation:**
- Worker pool exhaustion after a traffic burst with high abandon rate
- "Personalize bill is higher than expected" — wasted calls on abandoned requests
- p99 latency dragged up by old requests still processing

Reference: [Django — Async views and request handling](https://docs.djangoproject.com/en/5.0/topics/async/) | [Python — asyncio cancellation](https://docs.python.org/3/library/asyncio-task.html#task-cancellation)
