---
title: Use Refresh-Ahead Only for the Top 1% of Hot Keys
impact: HIGH
impactDescription: eliminates p99 spikes at TTL expiry on hot keys
tags: strat, refresh-ahead, hot-keys, top-of-distribution, p99
---

## Use Refresh-Ahead Only for the Top 1% of Hot Keys

When a hot key's TTL expires, the next request pays the full origin cost — and on a key receiving 100 req/s, that's not "one slow request," it's a 200ms p99 spike that's visible in dashboards. Refresh-ahead pre-emptively refreshes hot keys before they expire so traffic never hits a cold-key miss. The trade-off: refresh-ahead generates origin load even when no one is requesting the key. Apply it only to keys where the cost of the expiry spike outweighs the cost of speculative refresh — empirically, the top 1% of keys by traffic. Refreshing the long tail wastes origin and provides no user-visible benefit.

**Incorrect (refresh-ahead on every entry — wastes origin load):**

```typescript
async function search(q: string, ctx: Ctx) {
  const key = buildKey(q, ctx);
  const cached = await redis.get(key);
  if (cached) {
    // Always-on background refresh, even for keys hit once a week
    scheduleRefresh(key, () => opensearch.search(buildQuery(q, ctx)));
    return JSON.parse(cached);
  }
  // ... standard miss path
}
// Effect: refresh worker runs for every key. Origin traffic scales with cache size,
// not with hot-key traffic. ROI inverts at scale.
```

**Correct (gate refresh-ahead on the hot-key set):**

```typescript
// Maintain a small bloom filter of "hot keys" — refreshed nightly from access logs
const HOT_KEYS = await loadFromS3('s3://cache-analytics/hot-keys-today.bloom');
// Top 1% of keys by traffic = a few thousand keys for a typical marketplace.

async function search(q: string, ctx: Ctx) {
  const key = buildKey(q, ctx);
  const entry = await redis.get(key);

  if (entry) {
    const parsed = JSON.parse(entry);
    // Only refresh-ahead if this is a hot key AND it's within X% of TTL expiry
    if (HOT_KEYS.has(key) && shouldRefreshAhead(parsed.cachedAt, TTL_SECONDS)) {
      // Fire-and-forget refresh; current request still returns the cached value
      refreshQueue.push({ key, fetch: () => opensearch.search(buildQuery(q, ctx)), ttl: TTL_SECONDS });
    }
    return parsed.value;
  }

  // Cold miss — standard cache-aside path
  return loadAndCache(key, () => opensearch.search(buildQuery(q, ctx)), TTL_SECONDS);
}

function shouldRefreshAhead(cachedAt: number, ttlSeconds: number): boolean {
  // Refresh in the last 20% of the TTL window
  const ageSeconds = (Date.now() - cachedAt) / 1000;
  return ageSeconds > 0.8 * ttlSeconds;
}
```

**Combine with single-flight for the refresh worker.** The same key being eligible for refresh on multiple machines should result in ONE origin call across the fleet. Use [stamp-coalesce-concurrent-misses](stamp-coalesce-concurrent-misses.md) to ensure idempotency, or run the refresh worker as a single process per key class.

**How to identify hot keys:**
1. Sample `cache_hit` events with the key, sketch the distribution with HyperLogLog or Top-K
2. Daily batch: top 1% by hit count yesterday
3. Publish as a bloom filter (small, fast set-membership), ship to all instances

**The "predictable hot key" exception:** for known-hot keys (homepage banner, "trending now"), don't wait for analytics — mark them hot at design time. The bloom filter still applies; just seed it with the known set.

**When stale-while-revalidate beats refresh-ahead:** if the API supports RFC 5861 `stale-while-revalidate` (CDN edge, Service Worker), use that instead — see [stamp-serve-stale-on-rebuild](stamp-serve-stale-on-rebuild.md). The semantics are similar but driven by an inbound request rather than a background timer, so there's no wasted refresh for unused keys.

Reference: [AWS ElastiCache refresh-ahead pattern](https://docs.aws.amazon.com/whitepapers/latest/database-caching-strategies-using-redis/caching-patterns.html) · [Netflix EVCache cache warming](https://blog.bytebytego.com/p/how-netflix-warms-petabytes-of-cache)
