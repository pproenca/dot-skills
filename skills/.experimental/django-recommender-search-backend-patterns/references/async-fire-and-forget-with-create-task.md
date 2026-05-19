---
title: Use create_task for Fire-and-Forget Background Work
impact: MEDIUM
impactDescription: prevents user requests blocking on analytics/audit writes
tags: async, create-task, fire-forget, background, latency
---

## Use create_task for Fire-and-Forget Background Work

Some work doesn't need to complete before responding: analytics events, audit log writes, cache warming, downstream notification. `await`-ing these inside the view path means the user waits for them — adding 50-200ms of latency for work they don't see. `asyncio.create_task` schedules the coroutine to run independently; the view returns immediately, the work completes on its own.

The trap: detached tasks have no error handling by default. An exception inside a fire-and-forget task is logged as "Task exception was never retrieved" and the work silently failed. Always attach an error handler.

**Incorrect (await on side-effect work — adds to user-facing latency):**

```python
async def search_view(request):
    results = await opensearch_search(request.GET["q"])
    await analytics.track("search_performed", user_id=request.user.id, query=request.GET["q"])
    await audit_log.write("search", user=request.user.id)  # ❌ user waits for these
    return JsonResponse({"items": results})
```

**Correct (fire-and-forget the side effects):**

```python
async def search_view(request):
    results = await opensearch_search(request.GET["q"])

    # Fire-and-forget — view returns immediately, work runs after
    schedule_background(
        analytics.track("search_performed", user_id=request.user.id, query=request.GET["q"])
    )
    schedule_background(
        audit_log.write("search", user=request.user.id)
    )
    return JsonResponse({"items": results})

def schedule_background(coro):
    """Schedule a coroutine to run in the background with error handling."""
    task = asyncio.create_task(coro)
    task.add_done_callback(_log_task_error)
    return task

def _log_task_error(task: asyncio.Task):
    if task.cancelled():
        return
    exc = task.exception()
    if exc is not None:
        logger.error("background_task_failed",
                     task_name=task.get_name() or "unknown",
                     error_class=type(exc).__name__,
                     error=str(exc)[:200])
```

**Hold references to long-running tasks (or they may be garbage-collected):**

```python
# ❌ asyncio.create_task returns a task; Python may GC it if no reference is held
asyncio.create_task(slow_work())

# ✅ Hold a reference until done — set + discard pattern
_background_tasks: set[asyncio.Task] = set()

def schedule_background(coro):
    task = asyncio.create_task(coro)
    _background_tasks.add(task)
    task.add_done_callback(_background_tasks.discard)
    task.add_done_callback(_log_task_error)
    return task
```

**Don't fire-and-forget critical work:**

| Use create_task | Use await |
|-----------------|-----------|
| Analytics events | Database writes that the next request depends on |
| Audit logs (best-effort) | Audit logs where the API contract is "logged before response" |
| Cache warming | Cache writes the next request depends on |
| Webhook notifications | User-visible side effects (sending email confirmation, charging) |
| Search-result personalization log | Anything whose failure must be reported to the user |

**Bound the lifetime of background tasks:**

If you create_task in a view and the worker shuts down, the task is cancelled. For critical background work that must complete, use a task queue (Celery, RQ, Arq, Dramatiq) instead — those persist work to a queue and a separate worker processes it:

```python
# Persistent — survives worker restart
from celery import shared_task

@shared_task
def track_search(user_id, query):
    analytics.track("search_performed", user_id=user_id, query=query)

# In the view:
track_search.delay(user_id=request.user.id, query=request.GET["q"])
# delay() returns immediately; Celery worker handles it
```

**For multiple fire-and-forget tasks, batch them with a single error handler:**

```python
def schedule_background_batch(*coros):
    async def _runner():
        results = await asyncio.gather(*coros, return_exceptions=True)
        for i, r in enumerate(results):
            if isinstance(r, BaseException):
                logger.warning("background_batch_item_failed", index=i, error=str(r))
    return schedule_background(_runner())
```

**Bound concurrency on fire-and-forget (don't queue forever):**

```python
_background_semaphore = asyncio.Semaphore(50)  # max 50 background tasks at once

def schedule_background_bounded(coro):
    async def _bounded():
        async with _background_semaphore:
            await coro
    return schedule_background(_bounded())
```

Without a bound, a slow analytics endpoint can accumulate thousands of in-flight background tasks, consuming memory and connections.

**Don't fire-and-forget across request boundaries assuming completion:**

```python
# ❌ Subtle bug — the "ok" response implies the order was saved, but it might fail
async def create_order(request):
    schedule_background(db.save_order(request.data))
    return JsonResponse({"status": "ok"})

# ✅ Critical save MUST be awaited
async def create_order(request):
    await db.save_order(request.data)
    schedule_background(notify_warehouse(order_id))  # this can fail without user impact
    return JsonResponse({"status": "ok"})
```

**Send the analytics event with a fallback that doesn't block:**

```python
async def track_safely(event: str, **payload):
    try:
        async with asyncio.timeout(0.5):
            await analytics.track(event, **payload)
    except (asyncio.TimeoutError, AnalyticsError):
        # Best-effort — write to a local log queue for later replay
        local_queue.append({"event": event, "payload": payload, "ts": time.time()})

# Use it as fire-and-forget — even the fallback is bounded
schedule_background(track_safely("search_performed", user_id=..., query=...))
```

**Symptom of missing fire-and-forget:**
- User-facing latency dominated by background work (analytics, audit)
- "We added one more analytics event and p95 jumped 50ms"
- Slow analytics endpoint makes the whole API slow

Reference: [Python — asyncio.create_task](https://docs.python.org/3/library/asyncio-task.html#asyncio.create_task) | [Hynek — Background tasks](https://hynek.me/articles/fire-and-forget-tasks-asyncio/)
