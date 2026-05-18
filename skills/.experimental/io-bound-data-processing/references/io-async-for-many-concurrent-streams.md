---
title: Use Asyncio for Many Concurrent Network Streams
impact: CRITICAL
impactDescription: 10-100x more concurrent connections per core
tags: io, asyncio, concurrency, network, sockets
---

## Use Asyncio for Many Concurrent Network Streams

When most time is spent *waiting* on sockets — fetching 10,000 URLs, talking to many small services, fanning out to APIs — threads and processes don't help: each connection costs ~8 KiB of stack and a kernel-scheduled context switch on every wait. `asyncio` multiplexes thousands of waits onto a single thread with a few KiB per task and no kernel involvement on each `await`. The exact same code that takes 90 s synchronously (sequential network) and 20 s with a 50-thread pool runs in 2 s with `asyncio.gather` plus a semaphore — because the bottleneck was always wait-time, not compute.

**Incorrect (sequential network — each round-trip blocks everything):**

```python
import requests

results = []
for url in urls:                      # 10_000 URLs × 100 ms avg latency = 1000 s
    r = requests.get(url, timeout=10)
    results.append(r.json())
```

**Correct (asyncio + bounded concurrency):**

```python
import asyncio, aiohttp

async def fetch(session, sem, url):
    async with sem:                                   # cap in-flight requests
        async with session.get(url, timeout=10) as r:
            return await r.json()

async def fetch_all(urls, concurrency=100):
    sem = asyncio.Semaphore(concurrency)
    async with aiohttp.ClientSession() as session:
        return await asyncio.gather(*(fetch(session, sem, u) for u in urls))

results = asyncio.run(fetch_all(urls))               # ~10–20s instead of ~1000s
```

**Bound concurrency — don't `gather` 10k coroutines without a semaphore:**

A bare `gather` of 10k tasks opens 10k sockets simultaneously, exhausting the file-descriptor limit and overwhelming the remote server (which then 429s). The semaphore caps in-flight work without losing async benefit.

**When NOT to use asyncio:**
- The work is CPU-bound (parsing, decompression, hashing) — `asyncio` runs on one thread; use `concurrent.futures.ProcessPoolExecutor` or a thread pool that releases the GIL
- The library is blocking and has no async equivalent — wrapping it in `loop.run_in_executor` just adds overhead; a `ThreadPoolExecutor` is simpler (see [`conc-thread-pools-for-blocking-io-libraries`](conc-thread-pools-for-blocking-io-libraries.md))
- Tasks are few (< ~10) — `asyncio` startup cost outweighs the multiplexing win

Reference: [Python docs — asyncio](https://docs.python.org/3/library/asyncio.html), [aiohttp — Client](https://docs.aiohttp.org/en/stable/client.html)
