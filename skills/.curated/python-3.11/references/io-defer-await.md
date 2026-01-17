---
title: Defer await Until Value Needed
impact: CRITICAL
impactDescription: 2-5× faster for dependent operations
tags: io, asyncio, defer, promises, optimization
---

## Defer await Until Value Needed

Start async operations immediately but defer `await` until the value is actually needed. This allows multiple operations to run concurrently while the code proceeds.

**Incorrect (blocks immediately):**

```python
async def process_order(order_id: str) -> dict:
    order = await fetch_order(order_id)  # Blocks here
    user = await fetch_user(order.user_id)  # Waits for order first
    inventory = await check_inventory(order.items)  # Waits for user
    # Total: order + user + inventory
    return {"order": order, "user": user, "inventory": inventory}
```

**Correct (starts early, awaits late):**

```python
async def process_order(order_id: str) -> dict:
    order_task = asyncio.create_task(fetch_order(order_id))  # Starts immediately

    order = await order_task  # Now we need the order

    # Start both in parallel since they only need order data
    user_task = asyncio.create_task(fetch_user(order.user_id))
    inventory_task = asyncio.create_task(check_inventory(order.items))

    user = await user_task
    inventory = await inventory_task
    # Total: order + max(user, inventory)
    return {"order": order, "user": user, "inventory": inventory}
```

**Note:** Use `asyncio.create_task()` to start coroutines immediately. The task runs in the background until awaited.

Reference: [Python asyncio.create_task](https://docs.python.org/3/library/asyncio-task.html#asyncio.create_task)
