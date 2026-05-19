---
title: Batch Fan-out via Bulk Endpoints
impact: CRITICAL
impactDescription: reduces N parallel calls to 1 round-trip
tags: orch, batching, bulk, fanout, dataloader
---

## Batch Fan-out via Bulk Endpoints

Even with `asyncio.gather`, calling `/items/{id}` 50 times in parallel means 50 HTTP requests, 50 access-log entries, 50 rate-limit decrements, 50 database lookups on the downstream. One call to `/items?ids=a,b,c,...` does the same work as a single indexed lookup with `WHERE id IN (...)` — typically 10-50× faster on the database side too. Prefer bulk endpoints over parallel fan-out whenever the downstream supports it.

When the downstream only exposes per-item endpoints, build a request-scoped batcher (the DataLoader pattern from Facebook's Relay) that collects IDs requested in the same tick and fires one bulk call.

**Incorrect (parallel per-item calls — 50 round-trips):**

```python
async def enrich_results(items: list[dict]):
    sem = asyncio.Semaphore(10)
    async def _one(item):
        async with sem:
            return await enrichment_client.get(item["id"])
    enriched = await asyncio.gather(*(_one(i) for i in items))
    # 50 HTTP requests, even with bounded concurrency
```

**Correct (one bulk call when the endpoint exists):**

```python
async def enrich_results(items: list[dict]) -> list[dict]:
    ids = [item["id"] for item in items]
    details = await enrichment_client.get_bulk(ids)  # GET /items?ids=...
    by_id = {d["id"]: d for d in details}
    return [{**item, **by_id.get(item["id"], {})} for item in items]
# 1 HTTP request. Downstream: 1 indexed scan with WHERE id IN (...).
```

**Build a request-scoped batcher when only per-item endpoints exist:**

```python
# loaders.py
import asyncio
from typing import Any, Awaitable, Callable, Generic, TypeVar

K = TypeVar("K")
V = TypeVar("V")

class DataLoader(Generic[K, V]):
    """Collects calls within an event-loop tick and dispatches in bulk."""

    def __init__(
        self,
        batch_fn: Callable[[list[K]], Awaitable[dict[K, V]]],
        max_batch_size: int = 100,
    ):
        self._batch_fn = batch_fn
        self._max_batch_size = max_batch_size
        self._queue: list[tuple[K, asyncio.Future[V]]] = []
        self._dispatch_scheduled = False

    async def load(self, key: K) -> V:
        loop = asyncio.get_running_loop()
        future: asyncio.Future[V] = loop.create_future()
        self._queue.append((key, future))
        if not self._dispatch_scheduled:
            self._dispatch_scheduled = True
            loop.call_soon(self._dispatch)
        return await future

    def _dispatch(self):
        self._dispatch_scheduled = False
        batch = self._queue
        self._queue = []
        asyncio.create_task(self._run_batch(batch))

    async def _run_batch(self, batch: list[tuple[K, asyncio.Future[V]]]):
        keys = [k for k, _ in batch]
        try:
            results = await self._batch_fn(keys)
            for k, fut in batch:
                if k in results:
                    fut.set_result(results[k])
                else:
                    fut.set_exception(KeyError(f"key {k} not in batch response"))
        except Exception as e:
            for _, fut in batch:
                if not fut.done():
                    fut.set_exception(e)
```

**Usage of the batcher (request-scoped via middleware):**

```python
async def enrich_results(items: list[dict]):
    # Multiple unrelated code paths can all call .load(id) —
    # the batcher coalesces them into one bulk call
    loader = item_loader_for_this_request()  # per-request via context
    enriched = await asyncio.gather(*(loader.load(item["id"]) for item in items))
    return [{**items[i], **enriched[i]} for i in range(len(items))]
```

**Why request-scoped (not module-level):**
- Different requests have different auth contexts
- Different requests have different deadlines
- Module-level batching across requests creates fairness issues (one slow request blocks others)

**When NOT to batch:**
- Per-item calls have different parameters that don't compose (e.g., per-item authorization)
- The downstream's bulk endpoint has a much higher per-call cost than the per-item endpoint summed
- The batch window introduces latency (typically <1 tick of the event loop, but worth measuring)

**Pair with [[orch-bounded-fanout-concurrency]]:** if the batch exceeds `max_batch_size`, the batcher splits it — those splits then need bounded concurrency.

Reference: [graphql/dataloader](https://github.com/graphql/dataloader) | [Pyaponic/aiodataloader](https://github.com/syrusakbary/aiodataloader)
