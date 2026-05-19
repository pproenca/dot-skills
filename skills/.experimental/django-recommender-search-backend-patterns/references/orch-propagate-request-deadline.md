---
title: Propagate a Request Deadline Across All Downstreams
impact: CRITICAL
impactDescription: prevents unbounded request latency on slow downstream
tags: orch, deadline, timeout, slo, cancellation
---

## Propagate a Request Deadline Across All Downstreams

If your API SLO is 500ms p99, each downstream needs a timeout, but more importantly the *remaining* budget needs to shrink as work consumes time. Setting `timeout=500ms` on each of three downstreams means worst case = 500ms (not 1500ms — they're parallel) — but if Personalize takes 480ms, Databricks should be aborted at 20ms remaining, not granted another 500ms. Propagate a deadline: compute it once at request entry, pass the remaining budget to each downstream call.

This is the server-side equivalent of `AbortSignal` in the browser. In Python: an `asyncio.Task` wrapped in `asyncio.wait_for` per call, or `asyncio.timeout()` (3.11+) at the gather level.

**Incorrect (each call has its own clock — no whole-request bound):**

```python
async def recommendations_view(request):
    # Personalize takes 480ms, hits its per-call timeout of 500ms barely in time
    personalize = await personalize_client.get_recommendations(
        request.user.id, timeout=0.5
    )
    # Databricks given another 500ms even though we've already burned almost everything
    databricks = await databricks_client.invoke_ranker(
        request.user.id, items=[], timeout=0.5
    )
    # Total can be ~1s but the API promised 500ms — SLO breached, alert pages oncall
```

**Correct (deadline shared across the request):**

```python
import asyncio
import time

REQUEST_BUDGET_S = 0.5  # whole-request SLO

async def recommendations_view(request):
    deadline = time.monotonic() + REQUEST_BUDGET_S

    async with asyncio.timeout_at(deadline):  # Python 3.11+
        personalize, affinity, databricks = await asyncio.gather(
            personalize_client.get_recommendations(request.user.id),
            affinity_client.get_scored_items(request.user.id),
            databricks_client.invoke_ranker(request.user.id, items=[]),
            return_exceptions=True,
        )
    # If the deadline fires, TimeoutError raised here; all in-flight tasks cancelled
    return JsonResponse(blend_partial(personalize, affinity, databricks))
```

**Per-call budget from the shared deadline:**

```python
async def call_with_remaining_budget(deadline: float, coro):
    remaining = deadline - time.monotonic()
    if remaining <= 0:
        raise asyncio.TimeoutError("deadline already passed")
    return await asyncio.wait_for(coro, timeout=remaining)

# Inside the view:
deadline = time.monotonic() + 0.5
personalize, affinity = await asyncio.gather(
    call_with_remaining_budget(deadline, personalize_client.get(request.user.id)),
    call_with_remaining_budget(deadline, affinity_client.get(request.user.id)),
    return_exceptions=True,
)
```

**Propagate the deadline to HTTP clients (httpx):**

```python
async def call_personalize(user_id: str, deadline: float):
    remaining = max(0.01, deadline - time.monotonic())
    response = await client.post(
        "/personalize/recommend",
        json={"user_id": user_id},
        timeout=remaining,  # ← httpx accepts per-request timeout
    )
    return response.json()
```

**Propagate to downstream services via header (if they support it):**

```python
# When calling another internal service that can also bound work
headers = {"X-Request-Deadline-Ms": str(int((deadline - time.monotonic()) * 1000))}
# Downstream services that read this header can short-circuit expensive work
# and return partial results when their own deadline is near.
```

**Pair with [[protect-per-downstream-timeout-budget]]:** the *per-call* budget is `min(remaining_deadline, per_service_max_timeout)` — the per-service cap protects against a misbehaving caller that requests an unrealistic budget.

**Symptoms of missing deadline propagation:**
- p99 latency much higher than p95 (slow tail)
- Connection pool exhaustion under load (hanging requests hold connections)
- Workers stuck after a downstream outage (no deadline forces them to give up)

Reference: [Python — asyncio.timeout / timeout_at](https://docs.python.org/3/library/asyncio-task.html#timeouts) | [httpx — Timeouts](https://www.python-httpx.org/advanced/#timeout-configuration)
