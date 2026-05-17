---
title: Use XFetch Probabilistic Early Expiration for Hot Keys
impact: HIGH
impactDescription: smooths origin load by spreading refresh decisions across the TTL window
tags: stamp, xfetch, probabilistic, early-expiration, vattani
---

## Use XFetch Probabilistic Early Expiration for Hot Keys

Even with single-flight, a hot key still produces one origin call per TTL period — and that one call serves as a brief latency spike for whichever readers happened to arrive during it. XFetch (Vattani, Chierichetti, Lowenstein, VLDB 2015) eliminates the spike entirely: each reader independently rolls a die that becomes more likely to trigger an early refresh as the entry approaches expiry. With many concurrent readers, by the time the real expiry arrives, one of them has already done a background refresh. The origin sees a smooth refresh stream; no reader ever waits on a sync miss for hot keys.

**Incorrect (deterministic TTL — every refresh is a synchronous event for SOMEONE):**

```typescript
async function getHotKey(key: string, fetch: () => Promise<unknown>) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  // First reader after TTL pays the origin cost; others single-flight on the same call
  const fresh = await singleFlight(key, fetch);
  await redis.set(key, JSON.stringify(fresh), 'EX', 600);
  return fresh;
}
// p99 of the "unlucky first reader" includes origin latency.
```

**Correct (XFetch — probabilistic early refresh):**

```typescript
// XFetch entry: stores value, computed-at timestamp, delta (origin call duration in seconds), TTL
type XFetchEntry<T> = {
  value: T;
  computedAt: number;     // Unix seconds when the value was written
  delta: number;          // Seconds it took to compute (typical origin call duration)
  ttl: number;            // TTL in seconds
};

async function xfetchGet<T>(
  key: string,
  fetch: () => Promise<T>,
): Promise<T> {
  const raw = await redis.get(key);

  if (raw) {
    const entry = JSON.parse(raw) as XFetchEntry<T>;
    const now = Date.now() / 1000;
    const expiresAt = entry.computedAt + entry.ttl;
    const beta = 1.0;  // tuning parameter; >1 = more aggressive refresh

    // XFetch formula from Vattani et al.:
    //   refresh if  (now - delta*beta*ln(random)) >= expiresAt
    const xfetchTrigger = now - entry.delta * beta * Math.log(Math.random());

    if (xfetchTrigger >= expiresAt) {
      // Probabilistic decision: refresh early in the background, return current value
      singleFlight(key, async () => {
        const start = Date.now() / 1000;
        const fresh = await fetch();
        await write(key, fresh, Math.max(0.1, Date.now()/1000 - start), entry.ttl);
        return fresh;
      }).catch(err => log.warn('xfetch background refresh failed', err));

      return entry.value;
    }

    return entry.value;
  }

  // Cold miss — synchronous, with single-flight
  return singleFlight(key, async () => {
    const start = Date.now() / 1000;
    const fresh = await fetch();
    await write(key, fresh, Math.max(0.1, Date.now()/1000 - start), TTL_SECONDS);
    return fresh;
  });
}

async function write<T>(key: string, value: T, delta: number, ttl: number) {
  const entry: XFetchEntry<T> = {
    value,
    computedAt: Date.now() / 1000,
    delta,
    ttl,
  };
  await redis.set(key, JSON.stringify(entry), 'EX', ttl);
}
```

**Tuning beta:**
- `beta = 1.0` is the paper's default; works well for typical workloads
- Higher beta (1.5-2.0) refreshes more aggressively — fewer spikes, more origin load
- Lower beta (0.5-0.8) refreshes more conservatively — closer to standard TTL behaviour

**The delta intuition:** `delta` is "how long does the origin call take?" Hot keys with fast origins refresh closer to TTL; slow origins refresh further before TTL. The formula naturally accounts for this.

**When XFetch is overkill:**
- Low-rate keys (under 1 req/s): single-flight is sufficient; XFetch adds complexity for no win
- Keys with strong write-time invalidation (event-driven): no TTL-bound miss to smooth

**When XFetch is essential:**
- Hot keys (>10 req/s) with high origin cost (>100ms)
- Workloads where p99 latency at TTL boundaries is in the SLA
- Refresh-ahead with deterministic timer would over-refresh ([strat-refresh-ahead-hot-keys](strat-refresh-ahead-hot-keys.md))

**Versus stale-while-revalidate (RFC 5861):** SWR is similar but uses two TTLs (soft, hard) and serves stale during refresh. XFetch uses one TTL and prevents the sync miss in the first place by refreshing probabilistically. Both work; XFetch is simpler when you can measure `delta`.

Reference: [Vattani, Chierichetti, Lowenstein — Optimal Probabilistic Cache Stampede Prevention (VLDB 2015)](https://cseweb.ucsd.edu/~avattani/papers/cache_stampede.pdf) · [Probabilistic Early Expiration in Go (dizzy.zone)](https://dizzy.zone/2024/09/23/Probabilistic-Early-Expiration-in-Go/)
