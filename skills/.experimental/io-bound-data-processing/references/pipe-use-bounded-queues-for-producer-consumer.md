---
title: Bound Producer-Consumer Queues to a Fixed Size
impact: MEDIUM-HIGH
impactDescription: prevents unbounded memory growth; caps RAM at queue_size × item_size
tags: pipe, queue, producer-consumer, bounded, backpressure
---

## Bound Producer-Consumer Queues to a Fixed Size

An unbounded queue between a fast producer and slow consumer becomes a memory leak with deterministic shape: every second the producer adds N items, the consumer drains N − δ, the queue grows by δ forever. By the time you notice, the process is OOM-killed. A bounded queue inverts the contract — when full, the producer *blocks* — which is exactly the propagation mechanism for backpressure: the slow stage automatically throttles the fast stage upstream, no extra code needed.

**Incorrect (unbounded queue; producer outpaces consumer indefinitely):**

```python
import queue, threading

q = queue.Queue()       # default maxsize=0 means UNBOUNDED

def produce():
    for item in fast_source():
        q.put(item)     # never blocks; memory grows monotonically

def consume():
    while True:
        item = q.get()
        slow_process(item)

threading.Thread(target=produce, daemon=True).start()
consume()
```

**Correct (bounded queue; `put` blocks → producer throttles to consumer rate):**

```python
import queue, threading

q = queue.Queue(maxsize=1000)     # cap of 1000 items in flight

def produce():
    for item in fast_source():
        q.put(item)               # blocks when full → backpressure
    q.put(_SENTINEL)              # signal end-of-stream

def consume():
    while True:
        item = q.get()
        if item is _SENTINEL:
            return
        slow_process(item)
```

**With asyncio — same pattern, async semantics:**

```python
import asyncio

async def pipeline():
    q = asyncio.Queue(maxsize=1000)

    async def producer():
        async for item in fast_source():
            await q.put(item)     # awaits when full → applies backpressure
        await q.put(None)

    async def consumer():
        while (item := await q.get()) is not None:
            await slow_process(item)

    await asyncio.gather(producer(), consumer())
```

**Picking the size:**
- Big enough to absorb burstiness (consumer momentarily slow shouldn't stall producer immediately)
- Small enough that `queue_size × item_size << memory_budget`
- Rule of thumb: 100–10k items, sized so total queue memory ≤ 10–20% of working budget

**When unbounded queues are appropriate:**
- Producer is naturally bounded (finite known set; no chance of growth)
- The "queue" is a join buffer where the consumer is guaranteed faster — but verify with telemetry
- You're using a backpressure-aware framework (Reactive Streams, Trio nurseries) that bounds it for you

Reference: [Python docs — queue.Queue](https://docs.python.org/3/library/queue.html), [Python docs — asyncio.Queue](https://docs.python.org/3/library/asyncio-queue.html)
