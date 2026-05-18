---
title: Use Asyncio Only When the Bottleneck Is Waiting on I/O
impact: MEDIUM
impactDescription: prevents misapplied concurrency; 10x faster for I/O, no help for CPU
tags: conc, asyncio, io-bound, cpu-bound, concurrency-model
---

## Use Asyncio Only When the Bottleneck Is Waiting on I/O

`asyncio` is *not* a parallelism primitive — it's a multiplexer for *waiting*. One thread, one core, many awaits. When the bottleneck is hundreds of network sockets waiting for replies, asyncio is a 10–100× win because the kernel can interleave thousands of pending awaits. When the bottleneck is CPU (parsing, decompression, hashing, model inference), asyncio is the *wrong tool* — coroutines run sequentially on the event loop, and converting blocking calls to `await loop.run_in_executor(...)` just adds overhead over a plain thread/process pool. The first question on any concurrency design: which resource am I waiting on?

**Incorrect (asyncio for CPU-bound work — single core, plus event-loop overhead):**

```python
import asyncio, hashlib

async def hash_file(path):                   # CPU-bound; no I/O wait
    return hashlib.sha256(open(path, "rb").read()).hexdigest()

# All these run sequentially on the one event-loop thread.
await asyncio.gather(*(hash_file(p) for p in paths))   # no speedup vs serial
```

**Correct (process pool for CPU-bound; uses all cores):**

```python
from concurrent.futures import ProcessPoolExecutor
import hashlib

def hash_file(path):
    return hashlib.sha256(open(path, "rb").read()).hexdigest()

with ProcessPoolExecutor() as pool:
    hashes = list(pool.map(hash_file, paths))
```

**Asyncio is correct when waiting dominates — e.g., many small HTTP calls:**

```python
import asyncio, aiohttp

async def fetch_all(urls):
    sem = asyncio.Semaphore(100)
    async with aiohttp.ClientSession() as session:
        async def one(u):
            async with sem, session.get(u) as r:
                return await r.text()
        return await asyncio.gather(*(one(u) for u in urls))

# 10000 URLs at 100 in-flight: ~30s instead of ~hours sequentially.
```

**The decision matrix:**

| Bottleneck | Model | Why |
|---|---|---|
| Many sockets/files waiting | `asyncio` | One thread multiplexes thousands of awaits |
| Few blocking I/O calls (DB driver, etc.) | `ThreadPoolExecutor` | GIL releases during blocking syscalls |
| CPU work (parse, compress, model) | `ProcessPoolExecutor` | Bypasses GIL; uses all cores |
| Mix of network + CPU | asyncio + `run_in_executor` for CPU | Best of both, carefully |

**Spot the misuse:**

```python
# Anti-pattern: "let me asyncify this" with no I/O wait inside.
async def parse_event(blob):
    return json.loads(blob)             # pure CPU; the `async` adds zero benefit

# Anti-pattern: blocking call inside an async function — blocks the whole event loop.
async def fetch(url):
    return requests.get(url).json()     # `requests` is blocking; stalls all coroutines
```

**Mixing — only the CPU stage needs the executor:**

```python
import asyncio
from concurrent.futures import ProcessPoolExecutor

async def pipeline():
    loop = asyncio.get_running_loop()
    with ProcessPoolExecutor() as pool:
        async with aiohttp.ClientSession() as session:
            async def handle(url):
                async with session.get(url) as r:
                    raw = await r.read()                # I/O — asyncio
                return await loop.run_in_executor(pool, parse_heavy, raw)  # CPU — pool

            results = await asyncio.gather(*(handle(u) for u in urls))
    return results
```

Reference: [Python docs — asyncio](https://docs.python.org/3/library/asyncio.html), [Python docs — concurrent.futures](https://docs.python.org/3/library/concurrent.futures.html)
