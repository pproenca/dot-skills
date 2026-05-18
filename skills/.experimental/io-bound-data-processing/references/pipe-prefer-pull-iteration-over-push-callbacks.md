---
title: Prefer Pull Iteration Over Push Callbacks
impact: MEDIUM-HIGH
impactDescription: backpressure for free; prevents unbounded buffering
tags: pipe, pull-vs-push, iteration, callbacks, generators
---

## Prefer Pull Iteration Over Push Callbacks

Two ways to wire a pipeline: *pull* (consumer asks the producer for the next item; producer waits if nothing's ready) or *push* (producer fires items at the consumer's callback; consumer queues them up). Pull naturally applies backpressure — the producer is suspended between `next()` calls, so the consumer's pace dictates the producer's pace. Push doesn't — events arrive at the producer's pace, and the consumer needs an explicit bounded queue, drop policy, or rate limiter to avoid memory bloat. Prefer pull-based APIs (iterators, generators, async iterators, server-sent streams) whenever you can; treat callback APIs as an integration point to convert to pull.

**Incorrect (callback-based; no flow control):**

```python
# Library calls our callback for every event; we have no way to slow it down.
def on_event(event):
    queue.append(event)            # `queue` grows unbounded
    if len(queue) > 10_000:
        process_batch(queue)
        queue.clear()

client.subscribe(on_event)         # fires as fast as data arrives
```

**Correct (pull iteration; producer is suspended between requests):**

```python
# Iterator API: `for event in client.stream()` — producer yields only when consumer asks.
for event in client.stream():
    process(event)                  # producer is paused here; no backlog
```

**Async iterators — same property in async code:**

```python
async for event in client.astream():
    await process(event)            # backpressure applied by the `await`
```

**When you must adapt a push API → wrap it as pull with a bounded queue:**

```python
import asyncio

async def pushed_to_pull(subscribe_fn, max_queue=1000):
    q = asyncio.Queue(maxsize=max_queue)
    loop = asyncio.get_event_loop()

    def callback(event):
        # If queue is full, the callback drops or blocks — explicit policy.
        try:
            q.put_nowait(event)
        except asyncio.QueueFull:
            log.warning("dropping event; consumer too slow")

    subscribe_fn(callback)
    while True:
        yield await q.get()

async for event in pushed_to_pull(client.subscribe):
    await process(event)
```

**Pull patterns to prefer:**

| API style | Backpressure? | Examples |
|---|---|---|
| Sync iterator (`for x in src`) | ✅ implicit | file objects, db cursors, generators |
| Async iterator (`async for`) | ✅ implicit | `aiohttp` chunks, `asyncpg` streams |
| Pull-based stream (`recv()`) | ✅ via await | sockets, server-sent events |
| Callback (`subscribe(cb)`) | ❌ explicit policy needed | Kafka consumer (raw), WebSocket events |
| Reactive (`Observable`) | depends on framework | RxJS w/ backpressure operators only |

**When push is appropriate:**
- The downstream is genuinely faster than the upstream (telemetry into a fast collector)
- Drop-on-overflow is acceptable (metrics, samplable logs)
- Real-time systems where buffering is more harmful than drop

Reference: [Python docs — Iterators and generators](https://docs.python.org/3/tutorial/classes.html#iterators), [PEP 525 — Asynchronous generators](https://peps.python.org/pep-0525/)
