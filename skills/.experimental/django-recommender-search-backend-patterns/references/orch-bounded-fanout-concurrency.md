---
title: Bound Per-Request Fan-out with a Semaphore
impact: CRITICAL
impactDescription: prevents one user's request from saturating the pool
tags: orch, semaphore, fanout, concurrency, bulkhead
---

## Bound Per-Request Fan-out with a Semaphore

A "search + recommend" endpoint might fan out to N items (one per result) to fetch enrichment data — author info, inventory, price. With 50 results, that's 50 parallel calls *per request*. Even if downstream can handle 1000 RPS in aggregate, a single user request firing 50 concurrent calls exhausts the connection pool (typically 50-100 connections) and starves all other in-flight requests. Cap per-request fan-out with `asyncio.Semaphore`.

This is the per-request bulkhead. Combine with the per-downstream bulkhead from [[protect-bulkhead-connection-pool]]: connection-pool limits cap aggregate concurrency; semaphores cap per-request concurrency.

**Incorrect (uncapped fan-out — one user blocks the pool):**

```python
async def enrich_results(items: list[dict]) -> list[dict]:
    # 50 items → 50 parallel enrichment calls → pool exhausted
    enriched = await asyncio.gather(
        *(enrichment_client.get(item["id"]) for item in items),
        return_exceptions=True,
    )
    return [merge(items[i], enriched[i]) for i in range(len(items))]
```

**Correct (bounded with Semaphore):**

```python
async def enrich_results(items: list[dict]) -> list[dict]:
    sem = asyncio.Semaphore(8)  # at most 8 concurrent enrichment calls

    async def _enrich_one(item: dict) -> dict:
        async with sem:
            try:
                detail = await enrichment_client.get(item["id"])
                return merge(item, detail)
            except Exception:
                return item  # return without enrichment on failure

    return await asyncio.gather(*(_enrich_one(item) for item in items))
```

**Pick the cap based on what you're protecting:**

| Goal | Cap |
|------|-----|
| Protect connection pool (50 conns) | 8-16 per request (gives 3-6 simultaneous requests breathing room) |
| Respect downstream rate limit (200 RPS, 100 RPS budget for this view) | enrichment_qps_budget / request_rps |
| Bound CPU on local compute (e.g., embedding) | os.cpu_count() |
| Bound memory (each task ~50MB) | available_memory / per_task_memory |

**Prefer bulk endpoints over bounded fan-out:**

```python
# Best: bulk endpoint — one call, no fan-out needed
enriched = await enrichment_client.get_bulk([item["id"] for item in items])
# Acceptable: bounded fan-out (above)
# Worst: unbounded fan-out
```

**Reusable limiter for the codebase:**

```python
# utils/limiter.py
import asyncio
from contextlib import asynccontextmanager

class Limiter:
    def __init__(self, max_concurrency: int):
        self._sem = asyncio.Semaphore(max_concurrency)

    @asynccontextmanager
    async def slot(self):
        async with self._sem:
            yield

# Per-downstream limiters, shared across requests (kept at module scope)
PERSONALIZE_LIMITER = Limiter(20)
DATABRICKS_LIMITER = Limiter(10)

async def fetch_personalize(user_id: str):
    async with PERSONALIZE_LIMITER.slot():
        return await personalize_client.get(user_id)
```

**When the semaphore is saturated:**
- Tasks wait — they don't fail. Pair with [[orch-propagate-request-deadline]] so they don't wait forever
- Use `asyncio.wait_for(sem.acquire(), timeout=...)` for explicit max-wait

**Symptom of missing semaphores:** error rate spikes when one user fires a large request — the connection pool drains in a millisecond, other in-flight requests time out waiting for connections, the API looks broken for everyone.

Reference: [Python — asyncio.Semaphore](https://docs.python.org/3/library/asyncio-sync.html#asyncio.Semaphore) | [Microsoft — Bulkhead pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/bulkhead)
