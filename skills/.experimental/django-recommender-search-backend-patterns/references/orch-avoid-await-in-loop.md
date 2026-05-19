---
title: Avoid await Inside Independent Loops
impact: CRITICAL
impactDescription: reduces N sequential awaits to 1 round-trip time
tags: orch, asyncio, gather, loop, parallelism
---

## Avoid await Inside Independent Loops

`for item in items: result = await client.get(item.id)` runs sequentially even inside an async function — `await` yields control to the event loop, but the next iteration only starts after the previous returns. If 50 items each take 80ms, the loop takes 4 seconds. Use `asyncio.gather` over a list comprehension to fire them all in parallel (with the bounded-concurrency guardrail from [[orch-bounded-fanout-concurrency]]).

This is the most common parallelism bug in async Python — the syntax looks parallel because the function is async, but the loop runs serially.

**Incorrect (sequential loop — 50× slower than needed):**

```python
async def enrich_search_results(items: list[dict]) -> list[dict]:
    enriched = []
    for item in items:
        # ❌ Each await waits for the previous one to complete
        detail = await enrichment_client.get(item["id"])
        enriched.append({**item, **detail})
    return enriched
# 50 items × 80ms = 4000ms — and the user is waiting the whole time
```

**Correct (parallel via gather):**

```python
async def enrich_search_results(items: list[dict]) -> list[dict]:
    sem = asyncio.Semaphore(8)  # bounded concurrency — see [[orch-bounded-fanout-concurrency]]

    async def _fetch_one(item: dict) -> dict:
        async with sem:
            try:
                detail = await enrichment_client.get(item["id"])
                return {**item, **detail}
            except Exception:
                return item  # graceful: keep the unenriched item

    return await asyncio.gather(*(_fetch_one(item) for item in items))
# ~80ms × (50/8) = ~500ms — 8× faster, bounded pool pressure
```

**Pattern: process-as-they-complete with as_completed (when order doesn't matter):**

```python
async def enrich_streaming(items: list[dict]):
    tasks = [asyncio.create_task(enrichment_client.get(item["id"])) for item in items]
    enriched = []
    for completed in asyncio.as_completed(tasks):
        try:
            detail = await completed
            enriched.append(detail)
        except Exception:
            continue
    return enriched
# Useful when downstream calls have variable latency and you want to
# emit results to a stream or progress bar as each one finishes.
```

**When sequential IS correct:**

```python
# Genuinely dependent — each call needs the previous result
async def hierarchical_fetch(root_id: str):
    root = await api.get(root_id)
    parent = await api.get(root.parent_id)      # needs root.parent_id
    grandparent = await api.get(parent.parent_id)  # needs parent.parent_id
    return [root, parent, grandparent]
# No way to parallelize — each call is data-dependent on the previous.
```

**Detect this in code review:** look for any `for ... : await` pattern. Ask: "is the next iteration's call computable from inputs already known before the loop?" If yes, it's not actually dependent — it's a serial loop pretending to be async.

**Pair with [[orch-batch-with-bulk-endpoint]]:** even with `gather`, N parallel calls is worse than 1 bulk call. If the backend supports `GET /items?ids=a,b,c`, prefer that.

Reference: [Python — asyncio.as_completed](https://docs.python.org/3/library/asyncio-task.html#asyncio.as_completed)
