---
title: Use asyncio.gather() for Concurrent I/O
impact: CRITICAL
impactDescription: 2-10× throughput improvement
tags: io, asyncio, concurrency, gather, waterfalls
---

## Use asyncio.gather() for Concurrent I/O

When multiple I/O operations have no dependencies, execute them concurrently with `asyncio.gather()`. Sequential awaits create waterfalls where each operation waits for the previous one to complete.

**Incorrect (sequential execution, 3 round trips):**

```python
async def fetch_user_data(user_id: str) -> dict:
    profile = await fetch_profile(user_id)
    orders = await fetch_orders(user_id)
    preferences = await fetch_preferences(user_id)
    # Total time: profile + orders + preferences
    return {"profile": profile, "orders": orders, "preferences": preferences}
```

**Correct (concurrent execution, 1 round trip):**

```python
async def fetch_user_data(user_id: str) -> dict:
    profile, orders, preferences = await asyncio.gather(
        fetch_profile(user_id),
        fetch_orders(user_id),
        fetch_preferences(user_id),
    )
    # Total time: max(profile, orders, preferences)
    return {"profile": profile, "orders": orders, "preferences": preferences}
```

**When NOT to use this pattern:**
- When operations depend on each other's results
- When you need to handle individual failures differently (use `return_exceptions=True` or `asyncio.TaskGroup`)

Reference: [Python asyncio documentation](https://docs.python.org/3/library/asyncio-task.html#asyncio.gather)
