---
title: Promote to L1 In-Process Cache on L2 Hit
impact: HIGH
impactDescription: 95%+ of L1-eligible reads served in <100µs
tags: strat, tiered, l1, l2, promotion
---

## Promote to L1 In-Process Cache on L2 Hit

A two-tier cache (L1 in-process LRU + L2 ElastiCache) only pays off when popular keys live in L1. The promotion strategy on an L2 hit decides this: promote eagerly (write to L1 on every L2 hit) and L1 fills with the long tail too; promote lazily (only after seeing the same key N times in a short window) and only the truly hot keys are promoted. Both work; eager is simpler and the default. The tier composition turns an L1-eligible request from "1.5ms Redis RTT" into "100µs in-process read," and at typical homepage QPS that's the difference between needing a Redis cluster of 10 nodes vs 3.

**Incorrect (single-tier — every read pays L2 RTT):**

```typescript
async function getRecs(cohort: string, surface: string, locale: string) {
  const key = `recs:${surface}:${cohort}:${locale}`;
  const cached = await redis.get(key);   // 1.2-1.8ms per read
  if (cached) return JSON.parse(cached);
  // ... miss path
}
// At 100 req/s × 5 surfaces = 500 cache lookups/s, all hitting Redis.
// Throughput is bound by Redis ops/sec; expensive at scale.
```

**Correct (L1 in-process + L2 Redis, promote on L2 hit):**

```typescript
import { LRUCache } from 'lru-cache';  // or @caffeine/cache for Java, Caffeine for Kotlin

// L1: in-process LRU
const l1 = new LRUCache<string, unknown>({
  max: 10_000,           // ~10k entries — fits hot working set
  ttl: 30_000,           // 30s — shorter than L2 to bound staleness
  updateAgeOnGet: false, // don't extend TTL on read (would defeat short TTL)
});

async function getRecs(cohort: string, surface: string, locale: string) {
  const key = `recs:${surface}:${cohort}:${locale}`;

  // L1: in-process, ~50-200ns
  const l1Hit = l1.get(key);
  if (l1Hit !== undefined) {
    metrics.increment('cache.hit', { tier: 'l1', surface });
    return l1Hit;
  }

  // L2: ElastiCache, ~1.2ms
  const l2Hit = await redis.get(key);
  if (l2Hit) {
    const value = JSON.parse(l2Hit);
    l1.set(key, value);  // <-- promote eagerly
    metrics.increment('cache.hit', { tier: 'l2', surface });
    return value;
  }

  // Miss: origin
  const fresh = await fetchFromOrigin(cohort, surface, locale);
  await redis.set(key, JSON.stringify(fresh), 'EX', 1800);
  l1.set(key, fresh);  // populate L1 too
  metrics.increment('cache.hit', { tier: 'origin', surface });
  return fresh;
}

// At 500 cache lookups/s, with L1 hit rate ~80% (hot keys):
//   ~400 L1 lookups/s × 100ns      = essentially free
//   ~100 L2 lookups/s × 1.2ms      = manageable Redis load
//   Redis cluster sized for 100ops/s headroom, not 500.
```

**Key sizing decisions:**
- **L1 size:** small (5k-50k entries). Goal: hold the hot working set, not everything. Larger L1 = more memory per instance × N instances.
- **L1 TTL:** *shorter than L2*. Bounds staleness across instances. With 30s L1 TTL, no instance serves a value more than 30s + L2 TTL stale.
- **L2 size:** large enough to hold the broader working set (see [decide-hot-key-distribution](decide-hot-key-distribution.md)).
- **L2 TTL:** the "real" TTL (5-60 min depending on content volatility).

**The consistency caveat:** with N instances each holding their own L1, a write-through to L2 + per-instance L1 invalidation is the only way to ensure L1 doesn't lag L2. For most read-heavy paths, "L1 may be up to 30s stale" is acceptable; for read-after-write paths, route writes through a publish/subscribe channel (Redis Pub/Sub) that invalidates L1 across all instances.

**When L1 isn't worth it:**
- Reads under 100/s/instance — L2 latency already negligible
- Working set larger than L1 capacity by 10× — L1 churns, hit rate collapses
- Memory-constrained instances — the JVM heap pressure can dominate

**Netflix EVCache** uses exactly this pattern with Caffeine for L1 and Memcached for L2. Pinterest's Cachelib similarly. Both report L1 hit rates of 70-95% for recommender workloads.

Reference: [Netflix EVCache features](https://netflix.github.io/EVCache/features/) · [Caffeine cache (Java)](https://github.com/ben-manes/caffeine) · [Netflix Rend (Memcached proxy with L1/L2)](https://github.com/Netflix/rend)
