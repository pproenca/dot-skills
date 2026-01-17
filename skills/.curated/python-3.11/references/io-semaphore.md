---
title: Use Semaphores to Limit Concurrent Operations
impact: CRITICAL
impactDescription: prevents resource exhaustion
tags: io, semaphore, asyncio, rate-limiting
---

## Use Semaphores to Limit Concurrent Operations

Unbounded concurrency can exhaust resources like file descriptors, memory, or API rate limits. Use `asyncio.Semaphore` to cap concurrent operations.

**Incorrect (unbounded concurrency):**

```python
async def fetch_all_urls(urls: list[str]) -> list[str]:
    async def fetch(url: str) -> str:
        async with aiohttp.ClientSession() as session:
            async with session.get(url) as response:
                return await response.text()

    # Launches all requests simultaneously - may exhaust connections
    return await asyncio.gather(*[fetch(url) for url in urls])
```

**Correct (bounded concurrency):**

```python
async def fetch_all_urls(urls: list[str], max_concurrent: int = 10) -> list[str]:
    semaphore = asyncio.Semaphore(max_concurrent)

    async def fetch(url: str) -> str:
        async with semaphore:  # Limits concurrent requests
            async with aiohttp.ClientSession() as session:
                async with session.get(url) as response:
                    return await response.text()

    return await asyncio.gather(*[fetch(url) for url in urls])
```

**Alternative (connection pool with aiohttp):**

```python
async def fetch_all_urls(urls: list[str]) -> list[str]:
    connector = aiohttp.TCPConnector(limit=10)  # Built-in limiting
    async with aiohttp.ClientSession(connector=connector) as session:
        async def fetch(url: str) -> str:
            async with session.get(url) as response:
                return await response.text()

        return await asyncio.gather(*[fetch(url) for url in urls])
```

Reference: [asyncio.Semaphore documentation](https://docs.python.org/3/library/asyncio-sync.html#asyncio.Semaphore)
