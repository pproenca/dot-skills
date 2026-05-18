---
title: Use Thread Pools for Blocking I/O Libraries
impact: MEDIUM
impactDescription: 5-50x speedup on blocking-driver I/O; GIL released during syscalls
tags: conc, threads, gil, blocking-io, executor
---

## Use Thread Pools for Blocking I/O Libraries

The GIL is the Python concurrency boogeyman — but it releases during blocking I/O syscalls. While one thread is in `read()` waiting for the disk, another thread can run Python bytecode. This is why `ThreadPoolExecutor` *does* speed up jobs dominated by blocking I/O (DB drivers without async support, third-party HTTP libraries, filesystem operations) even though it doesn't help CPU-bound work. Reach for threads when the I/O library you must use is blocking and you don't want to rewrite it on asyncio.

**Incorrect (sequential blocking I/O — one slow call blocks the next):**

```python
import psycopg

# 100 DB queries × 10 ms each = 1 s, all serial.
results = []
with psycopg.connect(DSN) as conn:
    for q in queries:
        with conn.cursor() as cur:
            cur.execute(q)
            results.append(cur.fetchall())
```

**Correct (thread pool — GIL releases inside the driver's blocking call):**

```python
from concurrent.futures import ThreadPoolExecutor
import psycopg

def run_query(q):
    # One connection per worker; psycopg connections are not thread-safe.
    with psycopg.connect(DSN) as conn, conn.cursor() as cur:
        cur.execute(q)
        return cur.fetchall()

with ThreadPoolExecutor(max_workers=20) as pool:
    results = list(pool.map(run_query, queries))
# 100 queries / 20 workers ≈ 5 batches × 10 ms = ~50 ms wall-clock.
```

**For filesystem I/O — same pattern:**

```python
from concurrent.futures import ThreadPoolExecutor

def hash_path(path):
    with open(path, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()

# `read()` releases the GIL; threads truly overlap on disk-bound work.
with ThreadPoolExecutor(max_workers=8) as pool:
    hashes = dict(zip(paths, pool.map(hash_path, paths)))
```

**For `requests`/blocking HTTP — threads are fine, but consider `httpx` async:**

```python
from concurrent.futures import ThreadPoolExecutor
import requests

with ThreadPoolExecutor(max_workers=50) as pool:
    results = list(pool.map(lambda u: requests.get(u).json(), urls))
# Works, but at 1000s of concurrent calls, asyncio + aiohttp scales further.
```

**Sizing the pool:**
- I/O-bound: pool size = 2–4× CPU count, or higher if latency × throughput requires
- Network calls: pool size = (target_inflight) — usually 10–100; beyond ~200, switch to asyncio
- Each thread has ~8 MiB stack — 1000 threads is ~8 GiB just for stacks

**When threads are wrong:**
- CPU-bound work — GIL serializes; use `ProcessPoolExecutor`
- Tens of thousands of concurrent waits — thread-per-task doesn't scale; use asyncio
- Shared state without locks — race conditions; either use thread-safe primitives or partition state

**Thread-local resources — open per-thread, not shared:**

```python
import threading
_local = threading.local()

def get_conn():
    if not hasattr(_local, "conn"):
        _local.conn = psycopg.connect(DSN)
    return _local.conn

# Each worker thread maintains its own connection; no cross-thread sharing.
```

Reference: [Python docs — ThreadPoolExecutor](https://docs.python.org/3/library/concurrent.futures.html#threadpoolexecutor), [Python docs — Threading and the GIL](https://docs.python.org/3/library/threading.html)
