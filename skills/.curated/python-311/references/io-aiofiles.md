---
title: Use aiofiles for Async File Operations
impact: CRITICAL
impactDescription: prevents event loop blocking
tags: io, aiofiles, async, file-operations
---

## Use aiofiles for Async File Operations

Standard file operations block the event loop, preventing other coroutines from running. Use `aiofiles` for non-blocking file I/O in async applications.

**Incorrect (blocks event loop):**

```python
async def process_log_files(log_paths: list[str]) -> list[dict]:
    results = []
    for path in log_paths:
        with open(path, "r") as f:  # Blocks entire event loop
            content = f.read()
            results.append(parse_log(content))
    return results
```

**Correct (non-blocking):**

```python
import aiofiles

async def process_log_files(log_paths: list[str]) -> list[dict]:
    async def read_and_parse(path: str) -> dict:
        async with aiofiles.open(path, "r") as f:  # Non-blocking
            content = await f.read()
            return parse_log(content)

    return await asyncio.gather(*[read_and_parse(path) for path in log_paths])
```

**Alternative (thread pool for sync I/O):**

```python
async def process_log_files(log_paths: list[str]) -> list[dict]:
    loop = asyncio.get_running_loop()

    def read_sync(path: str) -> dict:
        with open(path, "r") as f:
            return parse_log(f.read())

    tasks = [loop.run_in_executor(None, read_sync, path) for path in log_paths]
    return await asyncio.gather(*tasks)
```

Reference: [aiofiles documentation](https://github.com/Tinche/aiofiles)
