---
title: Use Batch Endpoints Instead of Per-Item Calls
impact: CRITICAL
impactDescription: N calls to 1 batched call — 10-100× latency reduction
tags: io, batching, bulk-api, network, dataloader
---

## Use Batch Endpoints Instead of Per-Item Calls

Most well-designed APIs expose batch variants (`/users?ids=1,2,3`, `INSERT ... VALUES (...), (...), (...)`, `mset`, `multiGet`) precisely because individual calls amortize poorly: each one pays TLS, auth, framing, and routing overhead regardless of payload size. A single batched call typically handles 100-1000 items for less wall-clock time than two individual calls, because the cost is dominated by round trips, not per-item work. Reach for the batch variant whenever the loop body is "send one thing over the wire" and the call sites are inside the same logical operation.

**Incorrect (per-item calls — N round trips):**

```python
# Redis client — one round trip per key
for user_id in user_ids:                            # 500 ids
    pipe.append(redis.get(f"user:{user_id}"))       # 500 round trips
```

**Correct (single batch call):**

```python
keys = [f"user:{uid}" for uid in user_ids]
values = redis.mget(keys)                           # 1 round trip
```

**Alternative (auto-batching with DataLoader / accumulator):**

```javascript
// GraphQL / Node — DataLoader collects calls in one tick, batches them
import DataLoader from 'dataloader';
const userLoader = new DataLoader(ids => fetchUsersByIds(ids));

// Each call looks individual but is auto-batched per event-loop tick
const u1 = await userLoader.load(1);
const u2 = await userLoader.load(2);
// Underlying call: fetchUsersByIds([1, 2]) — one round trip
```

**When NOT to use this pattern:**
- When the API has a hard batch-size limit and N >> limit — chunk into batches of `limit` and `Promise.all` the chunks; see [`io-sequential-await-in-loop`](io-sequential-await-in-loop.md).
- When per-item operations need independent error handling — a partial-failure batch API helps; otherwise consider `Promise.allSettled` over individual calls.

Reference: [graphql/dataloader — batching and caching](https://github.com/graphql/dataloader)
