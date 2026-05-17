---
title: Compute Cache ROI Before Adding the Cache
impact: CRITICAL
impactDescription: prevents shipping caches that cost more than they save
tags: decide, roi, capacity-planning, personalize, opensearch
---

## Compute Cache ROI Before Adding the Cache

A cache is justified only when `request_rate × origin_cost × hit_rate > cache_infra_cost + serialization_cost`. Most teams add a cache because "Redis is cheap," then discover hit rates below 30%, working sets larger than memory, or serialization overhead exceeding the saved origin call. For AWS Personalize the math is sharper because you pay tiered per-transaction (currently $0.0556 per 1k for the first 72M/month, dropping to $0.0278 then $0.0139 at scale) plus a `minProvisionedTPS` floor billed per second regardless of traffic — and a 60% hit rate halves the variable portion only if the cache costs less than the savings.

**Incorrect (cache first, measure later):**

```typescript
// Ship the cache, hope it helps. No model of expected hit rate or cost.
async function getRecommendations(userId: string): Promise<Item[]> {
  const cached = await redis.get(`recs:${userId}`);
  if (cached) return JSON.parse(cached);
  const result = await personalize.getRecommendations({ userId });
  await redis.set(`recs:${userId}`, JSON.stringify(result), 'EX', 300);
  return result;
}
// Three months later: hit rate is 4%, Redis is at $800/mo, Personalize bill unchanged.
```

**Correct (model the ROI before writing the code):**

```typescript
// ROI worksheet — fill in measured values, then decide.
//
// Inputs (from production logs over a 7-day window):
//   request_rate           = 1000 req/s
//   personalize_cost       = $0.0556 per 1k transactions  -> $0.0000556/req  (tier 1)
//   p99_origin_latency_ms  = 80
//   measured_hit_rate*     = 0.55  (* from a shadow cache running 1 week without serving)
//   working_set_keys       = 2_400_000   (95th percentile of distinct keys/24h)
//   bytes_per_value        = 8_000        (compressed)
//
// Monthly volume = 1000 * 86400 * 30 = 2.59B requests/mo.
// First 72M billed at $0.0556/1k, next 648M at $0.0278/1k, remainder at $0.0139/1k.
//
// Cache cost @ ElastiCache cache.r7g.large: ~$120/mo, ~13GB usable
//   bytes_needed = working_set_keys * bytes_per_value = 19.2 GB  -> need r7g.xlarge ~$240/mo
//
// Origin savings  ≈ avg_unit_cost * 2.59B * hit_rate ≈ $0.0000167/req * 2.59B * 0.55
//                ≈ ~$24k/mo on the variable portion (rough; recompute per actual tier mix)
// Cache infra     = $240/mo
// Net savings     = ~$23.7k/mo at this volume — a clear win.
//
// At smaller scale (e.g. 50 req/s = 130M req/mo) the numbers shrink ~20x; cache wins
// flip negative once the working set forces a multi-node cluster. ALWAYS run the
// worksheet with YOUR measured volume and tier before deciding.
```

**The "shadow cache" technique:** run the cache code path without serving from it — only log what *would* have been a hit. This measures the actual hit rate against your real traffic distribution before committing infra spend. Pre-deployment hit-rate estimates are often off by a meaningful multiple; the shadow cache is the cheapest way to find that out before you've sized infra around the wrong number.

**When NOT to cache at all:**
- Hit rate below 20% — cache infra usually exceeds savings
- Working set exceeds memory budget by >2× — eviction churn destroys hit rate
- Origin latency under 10ms — serialization/network overhead is comparable
- Per-request cost under $0.00001 (e.g. a local index lookup) — Personalize is not in this class; OpenSearch shard cache might be

Reference: [AWS Personalize Pricing](https://aws.amazon.com/personalize/pricing/) · [AWS ElastiCache Pricing](https://aws.amazon.com/elasticache/pricing/)
