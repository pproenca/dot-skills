---
title: Overlap Compute With Prefetch
impact: MEDIUM
impactDescription: 1.5-2x throughput when I/O time ≈ compute time
tags: conc, prefetch, double-buffering, pipelining, overlap
---

## Overlap Compute With Prefetch

A common pipeline shape is "read batch N, process batch N, read batch N+1, process batch N+1". The reads and the processing are sequential — total time = read_time + process_time. If you instead read batch N+1 *while* processing batch N (one batch ahead, in a background thread or coroutine), total time = max(read_time, process_time), with no other change. The pattern is "double buffering" or "1-step prefetch", and it's nearly free to implement: a single bounded queue plus a producer thread. The win is up to 2× when the stages are balanced; smaller when one dominates the other.

**Incorrect (read and process serialized; CPU idle during reads, disk idle during compute):**

```python
import pyarrow.parquet as pq

pf = pq.ParquetFile("events.parquet")
for batch in pf.iter_batches(batch_size=100_000):
    # While compute runs, the disk is idle.
    # While the next read runs, the CPU is idle.
    process(batch)
```

**Correct (one batch in flight while compute runs):**

```python
import queue, threading
import pyarrow.parquet as pq

def prefetch(source, q, n=2):
    """Read up to n batches ahead in a background thread."""
    for item in source:
        q.put(item)
    q.put(None)        # sentinel

pf = pq.ParquetFile("events.parquet")
source = pf.iter_batches(batch_size=100_000)
q = queue.Queue(maxsize=2)        # 1-2 batches buffered = ~one compute time ahead
threading.Thread(target=prefetch, args=(source, q), daemon=True).start()

while (batch := q.get()) is not None:
    process(batch)                # next batch is already loading
```

**With asyncio — one task ahead, naturally:**

```python
import asyncio

async def producer(source, q):
    async for batch in source:
        await q.put(batch)
    await q.put(None)

async def consumer(q):
    while (batch := await q.get()) is not None:
        await process(batch)

async def main():
    q = asyncio.Queue(maxsize=2)
    await asyncio.gather(producer(source(), q), consumer(q))
```

**PyTorch `DataLoader` is the canonical example:**

```python
# num_workers=N spawns N processes that prefetch batches into the queue
# while the GPU/CPU works on the current one. prefetch_factor=2 means
# each worker has 2 batches queued.
loader = DataLoader(dataset, batch_size=64, num_workers=4, prefetch_factor=2)
```

**Sizing the prefetch buffer:**
- Size = 1 batch ahead is usually enough; larger increases memory without much extra hiding
- Bound the queue (rule `pipe-use-bounded-queues-for-producer-consumer`); never unbounded prefetch
- For very small per-batch compute, the queue overhead dominates — measure before adding

**When prefetch doesn't help:**
- The pipeline is dominated by one stage (one stage >> 5× the others) — overlap saves <5%
- Compute already saturates all cores — there's no free CPU to "use" during I/O wait
- Disk/network is the absolute bottleneck — prefetch just deepens the queue without speeding I/O

**Verification (compare with and without prefetch):**

```python
# Without prefetch, total = sum(read + process) per batch.
# With prefetch, total ≈ sum(max(read, process)) per batch.
# Profile with `time.perf_counter()` around the loop.
```

Reference: [PyTorch — DataLoader](https://pytorch.org/docs/stable/data.html), [TensorFlow — Data prefetching](https://www.tensorflow.org/guide/data_performance#prefetching)
