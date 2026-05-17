---
title: Cache Only When Origin p99 Exceeds the Latency Budget
impact: CRITICAL
impactDescription: prevents caches that add latency on hits
tags: decide, latency-budget, p99, serialization, redis-rtt
---

## Cache Only When Origin p99 Exceeds the Latency Budget

A cache lookup is not free: ElastiCache RTT is typically 0.5-1.5ms in the same AZ, plus 0.1-0.5ms for JSON deserialization on a 10KB payload. If your origin call takes 3ms (e.g. an OpenSearch term query against a hot shard with filter cache hit), adding Redis in front turns a 3ms call into a 4-5ms call on a *hit*, and 5-6ms on a *miss*. The cache only pays off when origin p99 exceeds (cache_rtt + deserialize) by a comfortable margin and the hit rate is high enough that the saved p99 dominates the added p50.

**Incorrect (cache a fast origin, increasing average latency):**

```typescript
// OpenSearch term query on a small index — already 4ms p99
async function getListingById(id: string): Promise<Listing> {
  const cached = await redis.get(`listing:${id}`);  // 1.2ms RTT
  if (cached) return JSON.parse(cached);            // 0.4ms deserialize
  // miss path:
  const result = await opensearch.get({ index: 'listings', id });  // 4ms
  await redis.set(`listing:${id}`, JSON.stringify(result), 'EX', 60);
  return result;
}
// Measured: p50 went from 2ms (direct) to 1.8ms (cache hit) — break-even.
//          p99 went from 4ms to 5.5ms because misses pay BOTH costs.
// The cache made things slower on average.
```

**Correct (compute the budget, then decide):**

```typescript
// Latency-budget worksheet:
//
//   origin_p99            = 280ms   (Personalize GetRecommendations under load)
//   origin_p50            = 80ms
//   cache_lookup_rtt      = 1.2ms   (ElastiCache same-AZ)
//   deserialize_overhead  = 0.6ms   (10KB JSON)
//   serialize_overhead    = 0.5ms   (only on miss)
//   expected_hit_rate     = 0.70
//
//   effective_p50 = hit_rate * (cache_rtt + deserialize) + (1-hit_rate) * (cache_rtt + origin_p50 + serialize)
//                 = 0.7 * 1.8 + 0.3 * 82.5 = 26ms
//                 vs origin-only p50 = 80ms                  -> saves 54ms
//
//   effective_p99 ≈ max(origin_p99 + cache_rtt + serialize) on the miss tail
//                ≈ 282ms vs origin-only 280ms                -> p99 ~flat
//
// Decision: cache is worth it for the p50 win on a slow origin. Skip for fast origins.

async function getRecommendations(userId: string): Promise<Item[]> {
  // ...standard cache-aside (see strat-cache-aside-default)
}
```

**Heuristic for "fast origin":** if origin p99 < 20ms and you're considering a remote cache (ElastiCache, Memcached), don't bother — use an in-process L1 ([tier-l1-in-process](tier-l1-in-process.md)) instead. In-process LRU is 50-200ns per lookup, well below origin latency, so the cache is "free" on hits.

**Personalize specifics:** GetRecommendations p99 is regularly 100-500ms under normal load and spikes to 1-2s during auto-scale events. Cache is always worth it for the latency win, separate from cost.

**OpenSearch specifics:** complex queries with function_score / kNN / rescore (see the sibling skill `opensearch-function-scoring-algorithms`) are 50-500ms — cache is worth it. Simple term queries with filter-context caching are 2-10ms — application cache often adds latency.

Reference: [ElastiCache latency benchmarks](https://aws.amazon.com/blogs/database/work-with-cluster-mode-on-amazon-elasticache-for-redis/) · [Amazon Personalize getting recommendations](https://docs.aws.amazon.com/personalize/latest/dg/getting-recommendations.html)
