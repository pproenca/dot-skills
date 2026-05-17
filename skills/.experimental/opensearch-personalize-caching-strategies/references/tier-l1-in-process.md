---
title: Use In-Process LRU as L1 for Sub-Millisecond Reads
impact: MEDIUM-HIGH
impactDescription: 1000x faster than Redis for hot keys; eliminates network RTT
tags: tier, l1, caffeine, lru, in-process
---

## Use In-Process LRU as L1 for Sub-Millisecond Reads

Even an optimal ElastiCache lookup is bound by network RTT (~1ms in-AZ, ~3ms cross-AZ) plus serialization (~0.5ms for a 10KB payload). For hot keys that are read thousands of times per second per instance, an in-process LRU cache eliminates both: lookups become ~100-200ns memory accesses with no serialization. Modern in-process caches (Caffeine for Java, lru-cache for Node, cachetools for Python) handle eviction, TTL, and concurrent access. L1 is most effective for read-heavy small payloads — recommender outputs, cohort assignments, user features, feature flag states.

**Incorrect (every read goes to Redis even for the hottest keys):**

```typescript
async function getCohortKey(userId: string): Promise<string> {
  const cached = await redis.get(`cohort:${userId}`);
  if (cached) return cached;
  const cohort = await computeCohort(userId);
  await redis.set(`cohort:${userId}`, cohort, 'EX', 3600);
  return cohort;
}
// Called 5 times per page (5 recommenders) × 100 page views/s = 500 Redis GETs/s
// at ~1ms each. Redis is a bottleneck for what is fundamentally a hot lookup.
```

**Correct (L1 LRU in-process, L2 Redis behind, populated on L2 hits and misses):**

```typescript
import { LRUCache } from 'lru-cache';

const l1 = new LRUCache<string, string>({
  max: 100_000,         // ~100k entries
  ttl: 60_000,          // 60s — shorter than L2 (3600s) to bound staleness across instances
  ttlAutopurge: true,   // auto-evict expired entries
  updateAgeOnGet: false,
});

async function getCohortKey(userId: string): Promise<string> {
  // L1 hit: ~100-200ns
  const l1Hit = l1.get(userId);
  if (l1Hit !== undefined) {
    metrics.increment('cache.hit', { tier: 'l1', class: 'cohort' });
    return l1Hit;
  }

  // L2 hit: ~1ms
  const l2Hit = await redis.get(`cohort:${userId}`);
  if (l2Hit) {
    l1.set(userId, l2Hit);  // promote
    metrics.increment('cache.hit', { tier: 'l2', class: 'cohort' });
    return l2Hit;
  }

  // Origin: compute, populate both tiers
  const cohort = await computeCohort(userId);
  await redis.set(`cohort:${userId}`, cohort, 'EX', 3600);
  l1.set(userId, cohort);
  metrics.increment('cache.hit', { tier: 'origin', class: 'cohort' });
  return cohort;
}

// At 500 cohort lookups/s/instance with 80% L1 hit rate:
//   400 L1 lookups/s × 200ns        = ~0.08ms total CPU
//   100 L2 lookups/s × 1ms          = ~100ms aggregate latency
//   Redis load drops 80%. Per-instance latency budget gains 0.8ms p50.
```

**Sizing L1:**
- Per-instance memory budget; e.g. 256MB JVM heap allowance → 100-200k LRU entries depending on payload size
- Working set should fit in L1 for the hottest content classes (cohort assignments: small, fits easily; rendered search results: harder)

**TTL on L1 (and why it's shorter than L2):**
- L1 TTL bounds staleness *across instances*. If L1 holds an entry for 60s, no two instances disagree by more than 60s + L2 TTL.
- L2 TTL bounds staleness vs origin. L1 ≤ L2 is the invariant.
- Common: L1 = 30-60s, L2 = 600-3600s, origin TTL = ∞ (or content-driven).

**Race during writes:** when an upstream mutation invalidates L2 (`redis.del`), N instances still hold stale L1 copies until their L1 TTL expires. For mutate-and-immediately-read paths, use [strat-write-through-mutations](strat-write-through-mutations.md) WITH per-instance L1 invalidation via Pub/Sub (Redis `PUBLISH cache-invalidate user:123` → all instances `l1.delete('cohort:user:123')`).

**Skip L1 for very-large entries.** A 1MB cached search result in L1 means 100 instances × 100MB = 10GB of duplicated memory across the fleet. L1 is for small, hot entries.

**Caffeine and EVCache are the canonical implementations.** Pinterest's Cachelib also exposes the same L1/L2 hybrid pattern. For Node, `lru-cache` is standard. For Python, `cachetools.TTLCache` works.

Reference: [Caffeine (Java)](https://github.com/ben-manes/caffeine) · [Netflix EVCache](https://netflix.github.io/EVCache/features/) · [Pinterest Cachelib](https://medium.com/pinterest-engineering/feature-caching-for-recommender-systems-w-cachelib-8fb7bacc2762)
