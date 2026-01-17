---
title: Use ThreadPoolExecutor for Blocking Calls in Async
impact: HIGH
impactDescription: prevents event loop blocking
tags: conc, threadpool, asyncio, blocking-calls
---

## Use ThreadPoolExecutor for Blocking Calls in Async

Blocking calls in async code freeze the entire event loop. Use `run_in_executor()` to offload blocking operations to a thread pool.

**Incorrect (blocks event loop):**

```python
import asyncio

async def process_image(image_path: str) -> bytes:
    # PIL operations are blocking - freezes all other coroutines
    with Image.open(image_path) as img:
        img = img.resize((800, 600))
        buffer = io.BytesIO()
        img.save(buffer, format="JPEG")
        return buffer.getvalue()
```

**Correct (offloads to thread pool):**

```python
import asyncio
from concurrent.futures import ThreadPoolExecutor

executor = ThreadPoolExecutor(max_workers=4)

def _process_image_sync(image_path: str) -> bytes:
    with Image.open(image_path) as img:
        img = img.resize((800, 600))
        buffer = io.BytesIO()
        img.save(buffer, format="JPEG")
        return buffer.getvalue()

async def process_image(image_path: str) -> bytes:
    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(executor, _process_image_sync, image_path)
```

**Alternative (default executor):**

```python
async def process_image(image_path: str) -> bytes:
    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(None, _process_image_sync, image_path)
    # None uses default ThreadPoolExecutor
```

Reference: [asyncio.loop.run_in_executor](https://docs.python.org/3/library/asyncio-eventloop.html#asyncio.loop.run_in_executor)
