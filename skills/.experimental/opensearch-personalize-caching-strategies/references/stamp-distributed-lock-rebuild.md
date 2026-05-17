---
title: Use a Distributed Lock to Coordinate Cross-Instance Cache Rebuilds
impact: HIGH
impactDescription: prevents N-machine duplicate origin calls during a fleet-wide cold start
tags: stamp, distributed-lock, redlock, rebuild, fleet
---

## Use a Distributed Lock to Coordinate Cross-Instance Cache Rebuilds

In-process single-flight ([stamp-coalesce-concurrent-misses](stamp-coalesce-concurrent-misses.md)) only deduplicates within one instance. With 20 application instances behind a load balancer, a hot key's miss can produce 20 concurrent origin calls — one per instance, each of which itself was already deduplicated. For most workloads this is acceptable: 20 calls is far less than 200, and the work is the same as 20 independent processes hitting cache for the first time. For very expensive rebuilds (a kNN index warmup, a multi-second Personalize batch call, a heavy aggregation), even 20 calls is too many. A distributed lock makes the rebuild single-flight across the whole fleet.

**Incorrect (in-process single-flight only; N instances × 1 origin call each):**

```typescript
const inFlight = new Map<string, Promise<unknown>>();

async function getExpensiveResource(key: string, fetch: () => Promise<unknown>) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  // Single-flight WITHIN this instance — but other instances will independently
  // fire their own origin call for the same key.
  let promise = inFlight.get(key);
  if (!promise) {
    promise = (async () => {
      try {
        return await fetch();
      } finally {
        inFlight.delete(key);
      }
    })();
    inFlight.set(key, promise);
  }
  const fresh = await promise;
  await redis.set(key, JSON.stringify(fresh), 'EX', 3600);
  return fresh;
}
// With 20 instances, a fleet-wide cold miss = 20 origin calls.
```

**Correct (distributed lock across instances):**

```typescript
import Redlock, { ResourceLockedError } from 'redlock';

const redlock = new Redlock([redis], {
  retryCount: 10,         // try to acquire 10 times
  retryDelay: 100,        // 100ms between tries
  retryJitter: 50,
});

async function getExpensiveResource<T>(
  key: string,
  fetch: () => Promise<T>,
): Promise<T> {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  let lock;
  try {
    // Try to acquire the lock with a TTL > expected fetch time
    lock = await redlock.acquire([`lock:${key}`], 30_000);

    // Re-check cache after acquiring the lock — someone may have populated it
    // while we were waiting for the lock
    const recheck = await redis.get(key);
    if (recheck) {
      await lock.release().catch(() => {});
      return JSON.parse(recheck);
    }

    // We hold the lock; we are THE rebuilder
    const fresh = await fetch();
    await redis.set(key, JSON.stringify(fresh), 'EX', 3600);
    return fresh;

  } catch (err) {
    if (err instanceof ResourceLockedError) {
      // Couldn't get the lock after retries — someone else is rebuilding.
      // Wait briefly and re-check the cache; if still empty, fall through to
      // the unlocked path (degraded: we'll do our own origin call).
      await sleep(500);
      const recheck = await redis.get(key);
      if (recheck) return JSON.parse(recheck);
      // Degraded path — don't block forever
      return await fetch();
    }
    throw err;
  } finally {
    if (lock) await lock.release().catch(() => {});
  }
}
```

**When to use a distributed lock vs in-process only:**

| Origin cost / rebuild time | Strategy |
|----------------------------|----------|
| <50ms | In-process single-flight only; N concurrent calls is fine |
| 50-500ms | In-process single-flight; consider distributed lock for very hot keys |
| 500ms-5s | Distributed lock recommended |
| >5s (heavy rebuild, batch jobs) | Distributed lock required + alerting |

**Lock TTL must exceed expected fetch time.** A 30s lock TTL is safe for sub-30s rebuilds. If the rebuild can take longer, increase the TTL or implement lock extension (re-acquire periodically while holding).

**Lock leakage:** if the lock holder crashes mid-rebuild, the lock auto-expires after TTL. The next contender acquires it and rebuilds. This is correct behaviour — beats holding a permanent lock.

**Apply to:**
- Personalize cohort warm-up after retrain
- Bloom filter rebuilds from analytics data
- Large aggregation cache writes
- Multi-step compose-then-cache pipelines

**Don't apply to:**
- Per-request cache misses (the request shouldn't wait for a lock)
- Cheap rebuilds where the lock overhead dominates
- High-cardinality keyspaces (lock contention is rare; cost > benefit)

**Redlock caveat:** Martin Kleppmann published a critique noting Redlock can violate mutual exclusion under network partitions and GC pauses. For correctness-critical use cases (financial, identity), prefer a coordination service (ZooKeeper, etcd, Consul). For cache-rebuild deduplication, Redlock's failure mode (occasionally two rebuilders) is acceptable.

Reference: [Redlock algorithm (Redis docs)](https://redis.io/docs/latest/develop/use/patterns/distributed-locks/) · [Kleppmann — How to do distributed locking](https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html)
