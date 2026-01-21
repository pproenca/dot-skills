---
title: Use asyncio for I/O-Bound Concurrency
impact: HIGH
impactDescription: 300% throughput improvement for I/O
tags: conc, asyncio, io-bound, event-loop
---

## Use asyncio for I/O-Bound Concurrency

For I/O-bound workloads (network, disk), asyncio provides the best performance with minimal overhead. Threading adds context-switch costs; multiprocessing adds process overhead.

**Incorrect (blocking synchronous I/O):**

```python
import requests

def fetch_all_apis(urls: list[str]) -> list[dict]:
    results = []
    for url in urls:
        response = requests.get(url)  # Blocks until complete
        results.append(response.json())
    return results
# 100 URLs × 200ms each = 20 seconds sequential
```

**Correct (async concurrent I/O):**

```python
import asyncio
import aiohttp

async def fetch_all_apis(urls: list[str]) -> list[dict]:
    async with aiohttp.ClientSession() as session:
        async def fetch(url: str) -> dict:
            async with session.get(url) as response:
                return await response.json()

        return await asyncio.gather(*[fetch(url) for url in urls])
# 100 URLs × max(200ms) = ~200ms concurrent
```

**When to use each model:**
- **asyncio**: I/O-bound, high concurrency (thousands of connections)
- **threading**: I/O-bound, simpler code, moderate concurrency
- **multiprocessing**: CPU-bound, true parallelism needed

Reference: [Real Python - asyncio](https://realpython.com/async-io-python/)
