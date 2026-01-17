---
title: Use uvloop for Faster Event Loop
impact: CRITICAL
impactDescription: 2-4× faster async I/O
tags: io, uvloop, asyncio, performance
---

## Use uvloop for Faster Event Loop

`uvloop` is a drop-in replacement for asyncio's event loop, built on libuv. It provides 2-4× faster I/O performance with a single configuration change.

**Incorrect (default event loop):**

```python
import asyncio

async def main():
    results = await asyncio.gather(
        fetch_users(),
        fetch_orders(),
        fetch_inventory(),
    )
    return results

if __name__ == "__main__":
    asyncio.run(main())  # Uses default event loop
```

**Correct (uvloop event loop):**

```python
import asyncio
import uvloop

async def main():
    results = await asyncio.gather(
        fetch_users(),
        fetch_orders(),
        fetch_inventory(),
    )
    return results

if __name__ == "__main__":
    uvloop.install()  # Single line change
    asyncio.run(main())  # Now uses uvloop
```

**Alternative (set policy explicitly):**

```python
import asyncio
import uvloop

asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())
```

**When NOT to use this pattern:**
- On Windows (uvloop is Unix-only)
- When debugging with asyncio debug mode

Reference: [uvloop documentation](https://github.com/MagicStack/uvloop)
