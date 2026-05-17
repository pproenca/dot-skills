---
title: Coalesce Concurrent Misses Into a Single Origin Call
impact: HIGH
impactDescription: reduces origin calls per cold key from N concurrent to 1
tags: stamp, single-flight, coalescing, stampede, dedup
---

## Coalesce Concurrent Misses Into a Single Origin Call

At >90% cache hit rate, most reads are fast. But when a hot key misses — TTL expiry, eviction, or first access after deploy — every concurrent reader on the same key fires its own origin call. For a hot key receiving 200 req/s, the moment of a miss generates 200 origin calls in milliseconds. The origin sees a stampede; latency spikes; some calls fail; failures retry. Single-flight (Go's `singleflight.Group`, equivalent patterns in other languages) collapses concurrent misses on the same key into ONE origin call — other waiters block on the in-flight result, get it when it returns, and write it once. The miss is paid once per key per TTL, not N times.

**Incorrect (every reader fires its own origin call on miss):**

```typescript
async function getRecs(key: string, fetch: () => Promise<unknown>) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  // 200 concurrent misses = 200 simultaneous origin calls
  const fresh = await fetch();
  await redis.set(key, JSON.stringify(fresh), 'EX', 600);
  return fresh;
}
// Symptoms: origin p99 latency spike at every TTL expiry; intermittent 503s.
```

**Correct (single-flight in the process; distributed lock if cross-instance protection needed):**

```typescript
// In-process single-flight using a simple Map<key, Promise>
const inFlight = new Map<string, Promise<unknown>>();

async function singleFlight<T>(key: string, fetch: () => Promise<T>): Promise<T> {
  const existing = inFlight.get(key);
  if (existing) return existing as Promise<T>;

  const promise = (async () => {
    try {
      return await fetch();
    } finally {
      inFlight.delete(key);  // clean up on success OR failure
    }
  })();

  inFlight.set(key, promise);
  return promise;
}

async function getRecs(key: string, fetch: () => Promise<unknown>) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  // All concurrent misses on this key share ONE origin call
  const fresh = await singleFlight(key, fetch);

  // Best-effort write — racy with parallel misses across instances but
  // the value is the same, so the race is harmless
  await redis.set(key, JSON.stringify(fresh), 'EX', 600);
  return fresh;
}
```

**Cross-instance coalescing (when in-process isn't enough):**

```typescript
// For very-expensive origins (e.g. retraining a tiny model, fetching a 50MB blob),
// use a distributed lock to ensure only ONE instance fetches across the fleet.
import { Redlock } from 'redlock';
const redlock = new Redlock([redis]);

async function getExpensiveResource(key: string, fetch: () => Promise<unknown>) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  // Try to acquire a 5-second lock on the key
  const lock = await redlock.acquire([`lock:${key}`], 5000).catch(() => null);
  if (!lock) {
    // Lock held by another instance — wait briefly, then re-check cache
    await sleep(100);
    const recheck = await redis.get(key);
    if (recheck) return JSON.parse(recheck);
    // Fall through to a non-locked fetch if still missing (degraded path)
  }

  try {
    const fresh = await fetch();
    await redis.set(key, JSON.stringify(fresh), 'EX', 600);
    return fresh;
  } finally {
    if (lock) await lock.release().catch(() => {});
  }
}
```

**Single-flight in popular languages:**
- **Go:** `golang.org/x/sync/singleflight` — standard library-quality, used by gRPC and many AWS SDKs
- **Java:** `Caffeine`'s `loadingCache` natively single-flights
- **Node.js:** the in-process `Map<key, Promise>` pattern above; or `p-memoize`, `mem`, `dataloader`
- **Python:** `asyncio.Lock` per key, or the `aiocache` library's `cached` decorator

**Always clean up `inFlight` on failure.** A common bug: the `delete` runs only on success, so a failing origin call leaves a permanently-broken entry that all subsequent readers wait on. Use `try/finally`.

**Stampede on write-miss vs read-miss:** the single-flight pattern is read-side. Write-side stampedes (e.g. N producers all trying to write the same key) are handled by idempotency, not by coalescing.

**Combine with stale-while-revalidate** ([stamp-serve-stale-on-rebuild](stamp-serve-stale-on-rebuild.md)) for the most resilient pattern: serve stale during the in-flight refresh; only block readers if there's no value at all.

Reference: [Go: singleflight package](https://pkg.go.dev/golang.org/x/sync/singleflight) · [Caffeine Java cache](https://github.com/ben-manes/caffeine) · [Wikipedia: cache stampede](https://en.wikipedia.org/wiki/Cache_stampede)
