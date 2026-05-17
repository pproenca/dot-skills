---
title: Separate Soft TTL (Async Refresh) from Hard TTL (Sync Miss)
impact: HIGH
impactDescription: prevents p99 spikes at TTL boundaries on hot keys
tags: ttl, soft, hard, swr, async-refresh
---

## Separate Soft TTL (Async Refresh) from Hard TTL (Sync Miss)

A single TTL means "at minute 5:00, every reader of this key misses simultaneously." Even with stampede protection, the next read pays the origin latency cost. The two-TTL pattern splits this: a *soft* TTL (e.g. 4:00) triggers an asynchronous background refresh while the current read returns the not-yet-stale value; the *hard* TTL (5:00) treats the entry as expired and forces a sync miss only if no refresh has happened. The p99 stays flat because reads almost never wait on the origin — they wait on the cache, and a background worker refreshes ahead of expiry.

**Incorrect (single TTL — readers see the latency spike at TTL expiry):**

```typescript
async function cacheGet(key: string, fetch: () => Promise<unknown>) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  // At TTL expiry, this branch fires for every reader of the key simultaneously
  const fresh = await fetch();  // 200ms origin call — visible as p99 spike
  await redis.set(key, JSON.stringify(fresh), 'EX', 300);
  return fresh;
}
```

**Correct (soft + hard TTL, async background refresh):**

```typescript
type Entry<T> = { value: T; softExpiresAt: number; hardExpiresAt: number };

async function cacheGet<T>(
  key: string,
  fetch: () => Promise<T>,
  softTtlSec: number,
  hardTtlSec: number,
): Promise<T> {
  const now = Date.now();
  const raw = await redis.get(key);

  if (raw) {
    const entry = JSON.parse(raw) as Entry<T>;

    if (now < entry.softExpiresAt) {
      // Fresh — return as is
      return entry.value;
    }

    if (now < entry.hardExpiresAt) {
      // Stale-but-usable — return immediately, refresh in the background
      // Use single-flight (see stamp-coalesce-concurrent-misses) to dedupe
      backgroundRefresh(key, fetch, softTtlSec, hardTtlSec);
      return entry.value;
    }

    // Hard-expired — fall through to synchronous miss
  }

  // Sync miss path
  const fresh = await fetch();
  await write(key, fresh, softTtlSec, hardTtlSec);
  return fresh;
}

async function write<T>(key: string, value: T, softTtlSec: number, hardTtlSec: number) {
  const now = Date.now();
  const entry: Entry<T> = {
    value,
    softExpiresAt: now + softTtlSec * 1000,
    hardExpiresAt: now + hardTtlSec * 1000,
  };
  // Redis TTL is the *hard* TTL; soft is enforced in application code
  await redis.set(key, JSON.stringify(entry), 'EX', hardTtlSec);
}

// Usage:
//   softTtl = 240s, hardTtl = 300s
//   For 4 minutes, reads see fresh value.
//   In minute 4-5, reads see stale value + trigger background refresh.
//   After minute 5, reads sync-miss only if background refresh failed.
```

**Why this is RFC 5861's `stale-while-revalidate`:** the IETF standardised exactly this pattern for HTTP. The server returns `Cache-Control: max-age=240, stale-while-revalidate=60` and intermediaries (CDN, browser) implement the soft/hard semantics natively. Use the HTTP header when you control the edge cache, and the application-level pattern above when the cache is in your service code.

**Single-flight on the refresh:** the background-refresh-trigger must use single-flight ([stamp-coalesce-concurrent-misses](stamp-coalesce-concurrent-misses.md)) so N concurrent readers in the soft-stale window trigger ONE origin call, not N.

**Gap between soft and hard:** typically 10-25% of the hard TTL. A 5-min hard TTL with a 4-min soft TTL gives 1 min of stale-but-refreshing tolerance. Too narrow and refresh doesn't have time to complete; too wide and you serve stale longer than needed.

**Don't apply when staleness is harmful.** For inventory counts or user-mutated state, stale = wrong. Use the read-after-write write-through pattern ([strat-write-through-mutations](strat-write-through-mutations.md)) and a short single TTL instead.

Reference: [RFC 5861 — stale-while-revalidate](https://datatracker.ietf.org/doc/html/rfc5861) · [web.dev: stale-while-revalidate](https://web.dev/articles/stale-while-revalidate)
