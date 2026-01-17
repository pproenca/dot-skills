---
title: Use Connection Pooling for Database Access
impact: CRITICAL
impactDescription: 100-200ms saved per connection
tags: io, database, connection-pool, latency
---

## Use Connection Pooling for Database Access

Creating database connections is expensive, typically taking 100-200ms. Connection pools maintain reusable connections, eliminating this overhead for each query.

**Incorrect (new connection per query):**

```python
async def get_user(user_id: int) -> dict:
    conn = await asyncpg.connect(DATABASE_URL)  # 100-200ms overhead
    try:
        row = await conn.fetchrow("SELECT * FROM users WHERE id = $1", user_id)
        return dict(row)
    finally:
        await conn.close()

async def get_orders(user_id: int) -> list:
    conn = await asyncpg.connect(DATABASE_URL)  # Another 100-200ms overhead
    try:
        rows = await conn.fetch("SELECT * FROM orders WHERE user_id = $1", user_id)
        return [dict(row) for row in rows]
    finally:
        await conn.close()
```

**Correct (shared connection pool):**

```python
pool: asyncpg.Pool | None = None

async def init_pool():
    global pool
    pool = await asyncpg.create_pool(DATABASE_URL, min_size=5, max_size=20)

async def get_user(user_id: int) -> dict:
    async with pool.acquire() as conn:  # Reuses existing connection
        row = await conn.fetchrow("SELECT * FROM users WHERE id = $1", user_id)
        return dict(row)

async def get_orders(user_id: int) -> list:
    async with pool.acquire() as conn:  # Reuses existing connection
        rows = await conn.fetch("SELECT * FROM orders WHERE user_id = $1", user_id)
        return [dict(row) for row in rows]
```

Reference: [asyncpg documentation](https://magicstack.github.io/asyncpg/current/usage.html#connection-pools)
