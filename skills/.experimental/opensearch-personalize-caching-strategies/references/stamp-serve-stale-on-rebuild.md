---
title: Serve Stale While Refresh Is In Flight
impact: HIGH
impactDescription: prevents p99 spikes during origin slowdown or outage
tags: stamp, stale-while-revalidate, swr, fallback, resilience
---

## Serve Stale While Refresh Is In Flight

When a refresh is triggered (soft TTL expiry, manual invalidate, retrain event) and the origin call takes longer than expected, readers either wait for the slow origin or get an error. Both degrade user experience. The stale-while-revalidate pattern returns the previous (stale) value to readers immediately while the refresh runs in the background. Combined with `stale-if-error` semantics, the same pattern survives an origin outage: readers keep getting last-known-good for the configured stale window rather than 5xx errors. RFC 5861 codifies these directives for HTTP; the same logic applies to in-process and Redis-tier caches.

**Incorrect (block readers during refresh; fail readers during origin outage):**

```typescript
async function getRecs(key: string, fetch: () => Promise<unknown>) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  // Origin is slow today (p99 = 2s). Every miss waits the full 2s.
  // Origin is down right now. Every miss returns 5xx.
  const fresh = await fetch();
  await redis.set(key, JSON.stringify(fresh), 'EX', 300);
  return fresh;
}
```

**Correct (serve stale while refresh in flight; serve stale on origin error):** entry envelope tracks both a fresh window and a stale window:

```typescript
type StaleEntry<T> = {
  value: T;
  freshUntil: number;   // soft TTL expiry — within this, serve as fresh
  staleUntil: number;   // hard TTL expiry — serve stale up to here
};
```

Read path branches on which window the entry is in:

```typescript
async function getRecs<T>(
  key: string,
  fetch: () => Promise<T>,
  freshTtlSec: number,
  staleWindowSec: number,
): Promise<T> {
  const now = Date.now();
  const raw = await redis.get(key);

  if (raw) {
    const entry = JSON.parse(raw) as StaleEntry<T>;
    if (now < entry.freshUntil) return entry.value;  // fresh

    if (now < entry.staleUntil) {
      // Stale-but-acceptable: refresh in background, return stale immediately
      refreshInBackground(key, fetch, freshTtlSec, staleWindowSec);
      return entry.value;
    }
    // Beyond stale window — fall through to sync miss
  }

  // Sync miss (or hard-expired)
  try {
    const fresh = await singleFlight(key, fetch);
    await write(key, fresh, freshTtlSec, staleWindowSec);
    return fresh;
  } catch (err) {
    // Origin failure — last-resort: serve stale even past staleUntil
    if (raw) {
      log.warn('serving expired-stale on origin error', { key, err });
      return JSON.parse(raw).value;
    }
    throw err;
  }
}
```

Background refresh is single-flighted so concurrent readers in the stale window don't fire N origin calls:

```typescript
async function refreshInBackground<T>(
  key: string,
  fetch: () => Promise<T>,
  freshTtlSec: number,
  staleWindowSec: number,
) {
  singleFlight(key, async () => {
    try {
      const fresh = await fetch();
      await write(key, fresh, freshTtlSec, staleWindowSec);
      return fresh;
    } catch (err) {
      // Background refresh failed — leave stale entry as-is; it'll get retried
      log.warn('background refresh failed', { key, err });
      throw err;
    }
  }).catch(() => {});
}
```

**HTTP / CDN-level semantics (RFC 5861):**

```http
Cache-Control: max-age=300, stale-while-revalidate=60, stale-if-error=86400
```
- `max-age=300`: fresh for 5 minutes
- `stale-while-revalidate=60`: after fresh, serve stale up to 60s while async-refreshing
- `stale-if-error=86400`: if origin returns 5xx during the refresh, serve stale up to 24h

CloudFront, Fastly, Cloudflare, browser caches, and Service Workers all implement these directives. Configure the origin response headers from the same staleness budget ([ttl-bound-by-staleness-tolerance](ttl-bound-by-staleness-tolerance.md)).

**Don't apply to write-after-read paths.** A user who just updated their favourites and then re-reads should NOT see a stale "fresh" entry from before their write. Use write-through ([strat-write-through-mutations](strat-write-through-mutations.md)) for those paths.

**Stale-if-error is the most overlooked piece.** Origin slowdowns are rare; origin outages are rarer but more painful. Configuring `stale-if-error` with a generous window (hours) means a brief outage produces stale serves rather than errors. Pair with an alert so the team knows the origin is down — staleness shouldn't mask incidents.

Reference: [RFC 5861 — HTTP Cache-Control Extensions for Stale Content](https://datatracker.ietf.org/doc/html/rfc5861) · [web.dev: stale-while-revalidate](https://web.dev/articles/stale-while-revalidate) · [Fastly: Lifetime and revalidation](https://www.fastly.com/documentation/guides/concepts/edge-state/cache/stale/)
