---
title: Propagate Backpressure From the Slowest Stage
impact: MEDIUM-HIGH
impactDescription: prevents unbounded buffering; matches pipeline throughput to the bottleneck
tags: pipe, backpressure, flow-control, throttling
---

## Propagate Backpressure From the Slowest Stage

A multi-stage pipeline has exactly one throughput-limiting stage — the bottleneck — and any work the upstream does faster than that just piles up in buffers between them. Backpressure is the mechanism that lets the slow stage *push back* on the fast one, throttling production to match consumption. Pull-based iteration backpressures naturally (the consumer asks; the producer waits). Push-based callbacks or events don't — they emit at the producer's rate and accumulate at the consumer's queue. The fix is to add an explicit handshake: bounded queues, credit-based flow control, or `await` on consumer acknowledgment.

**Incorrect (fire-and-forget push; no signal from consumer to slow down):**

```python
import asyncio

async def producer(handler):
    async for record in fast_source():
        asyncio.create_task(handler(record))      # spawns unbounded tasks

async def slow_handler(record):
    await asyncio.sleep(0.5)                      # slow downstream
    await db.save(record)

# Producer outpaces handler; create_task accumulates pending coroutines in memory.
await producer(slow_handler)
```

**Correct (explicit backpressure via a bounded semaphore):**

```python
import asyncio

async def producer(handler, max_inflight=100):
    sem = asyncio.Semaphore(max_inflight)

    async def wrapped(record):
        try:
            await handler(record)
        finally:
            sem.release()                              # release when task finishes

    tasks = []
    async for record in fast_source():
        await sem.acquire()                            # producer waits when N in flight
        task = asyncio.create_task(wrapped(record))    # release happens in the task
        tasks.append(task)
    await asyncio.gather(*tasks)
```

The producer's `await sem.acquire()` blocks once `max_inflight` tasks are running; each task releases the slot in its `finally` block. This is the genuine handshake — the producer literally cannot get ahead of the consumer by more than `max_inflight` records.

**Better — pull-based iteration backpressures for free:**

```python
async def pipeline():
    async for record in fast_source():       # producer
        processed = await transform(record)  # CPU stage
        await db.save(processed)             # slow sink — this `await` is the backpressure
# Each `await` makes the loop wait; the producer never gets ahead.
```

**For HTTP / external APIs — server's 429/Retry-After is backpressure too:**

```python
async def submit(items):
    for item in items:
        while True:
            r = await client.post("/ingest", json=item)
            if r.status_code == 429:
                wait = int(r.headers.get("Retry-After", "1"))
                await asyncio.sleep(wait)
                continue
            break
```

**Signs you have a backpressure problem:**
- RSS grows linearly during a job that "should" be O(1) memory
- Queue length / pending-tasks count monotonically increases
- Process OOMs minutes into a job that ran fine on a small input
- Latency under load grows much faster than utilization

**When backpressure is unnecessary:**
- Producer is bounded and small enough to fit in memory — buffer the whole thing once
- Consumer is reliably faster than the producer — measure first, don't assume

Reference: [Reactive Streams — Backpressure](https://www.reactive-streams.org/), [aiohttp — Streaming](https://docs.aiohttp.org/en/stable/streams.html)
