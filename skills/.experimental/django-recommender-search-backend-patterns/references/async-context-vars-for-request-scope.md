---
title: Use contextvars for Request-Scoped State Across Async Calls
impact: MEDIUM
impactDescription: prevents cross-request state leakage in async code
tags: async, contextvars, request-scope, threading, isolation
---

## Use contextvars for Request-Scoped State Across Async Calls

In sync Django, request-scoped state (the current user, request ID, locale) often lives in thread-local storage (`threading.local()`). This works because each request gets a dedicated thread. In async views, *one thread handles many concurrent requests* — thread-local storage spills across requests, and a value set by request A is visible to request B running on the same thread between awaits.

`contextvars.ContextVar` is the asyncio-aware equivalent: variables are bound to the current task / async context, so each request has its own logical "thread-local" storage even when threads are shared. Use this for request IDs, current user, deadlines, locale — anything that needs to travel through nested async calls without explicit parameter threading.

**Incorrect (thread-local in async — cross-request contamination):**

```python
# auth.py
import threading
_thread_local = threading.local()

def set_current_user(user):
    _thread_local.user = user  # ❌ shared across async requests

def get_current_user():
    return getattr(_thread_local, "user", None)

# middleware.py
async def auth_middleware(get_response, request):
    set_current_user(request.user)
    response = await get_response(request)  # ← awaits here; other requests run on same thread
    return response

# Inside another concurrent request, get_current_user() returns wrong user
```

**Correct (contextvars — isolated per async task):**

```python
# auth.py
import contextvars

_current_user: contextvars.ContextVar = contextvars.ContextVar("current_user", default=None)

def set_current_user(user):
    return _current_user.set(user)  # returns a Token for restoring

def get_current_user():
    return _current_user.get()

def reset_current_user(token):
    _current_user.reset(token)

# middleware.py
async def auth_middleware(get_response, request):
    token = set_current_user(request.user)
    try:
        response = await get_response(request)
    finally:
        reset_current_user(token)
    return response
# Each request has its own value; no leakage across concurrent requests
```

**Common request-scoped contextvars:**

```python
# context.py
import contextvars
import time

request_id: contextvars.ContextVar[str | None] = contextvars.ContextVar("request_id", default=None)
current_user: contextvars.ContextVar = contextvars.ContextVar("current_user", default=None)
request_deadline: contextvars.ContextVar[float | None] = contextvars.ContextVar(
    "request_deadline", default=None
)
locale: contextvars.ContextVar[str] = contextvars.ContextVar("locale", default="en-US")

# Set them in middleware
async def context_middleware(get_response, request):
    tokens = [
        request_id.set(request.headers.get("X-Request-ID", str(uuid.uuid4()))),
        current_user.set(request.user),
        request_deadline.set(time.monotonic() + 0.5),
        locale.set(request.META.get("HTTP_ACCEPT_LANGUAGE", "en-US").split(",")[0]),
    ]
    try:
        return await get_response(request)
    finally:
        for t in tokens:
            try:
                t.var.reset(t)
            except LookupError:
                pass
```

**Use them in deeply nested code (no parameter threading):**

```python
# clients/personalize.py — needs the request deadline but isn't passed it explicitly
async def get_recommendations(user_id: str):
    deadline = request_deadline.get()
    timeout = max(0.01, deadline - time.monotonic()) if deadline else 2.0

    return await client.post(url, json={...}, timeout=timeout)
```

**Pass context to fire-and-forget tasks (or it's lost):**

```python
# By default, asyncio.create_task inherits the current context
async def search_view(request):
    # Context is set by middleware
    asyncio.create_task(track_event("search"))  # ✅ inherits context
    return JsonResponse({...})

async def track_event(event):
    user = current_user.get()        # works — inherited from request context
    req_id = request_id.get()
    await analytics.send(event, user_id=user.id, request_id=req_id)
```

**Don't pass context to long-lived background workers (different lifecycle):**

```python
# Celery worker doesn't share the request's contextvars
@shared_task
def track_event_celery(event, user_id, request_id):
    # Pass values explicitly — they were captured at task submission time
    analytics.send(event, user_id=user_id, request_id=request_id)

# When scheduling, capture context explicitly:
track_event_celery.delay(
    event="search",
    user_id=current_user.get().id,
    request_id=request_id.get(),
)
```

**For OpenTelemetry-style propagation:**

Tracing libraries (OpenTelemetry, Datadog APM) already use contextvars under the hood for trace IDs. The pattern above is the same — just don't reinvent it for trace propagation; use the tracing library's API.

**Don't store mutable state in contextvars:**

```python
# ❌ Storing a dict and mutating it — surprises on concurrent updates
request_state: contextvars.ContextVar[dict] = contextvars.ContextVar("state", default={})
request_state.get()["count"] += 1  # mutates the shared default dict across requests!

# ✅ Set a new dict each time
state = dict(request_state.get())
state["count"] = state.get("count", 0) + 1
request_state.set(state)
```

The default value is shared across all reads until `.set()` is called.

**Thread-aware context bridging (when calling sync code from async):**

```python
# sync_to_async with thread_sensitive=True respects contextvars correctly
# (provided you've set them via contextvars, not threading.local)
result = await sync_to_async(sync_function, thread_sensitive=True)(args)
# sync_function can call current_user.get() and see the right value
```

**Symptom of missing contextvars (using thread-locals in async):**
- Random "wrong user" or "wrong request ID" in logs
- Sporadic "cross-request data leakage" reported in security review
- Tests pass locally (one request at a time) but fail under concurrent load

Reference: [Python — contextvars](https://docs.python.org/3/library/contextvars.html) | [PEP 567 — Context Variables](https://peps.python.org/pep-0567/)
