---
title: Sample Key Cardinality Daily; Alert on Explosion
impact: HIGH
impactDescription: prevents 50-90% hit-rate collapse from silent canonicalisation regressions
tags: obs, cardinality, hyperloglog, normalisation, regression
---

## Sample Key Cardinality Daily; Alert on Explosion

When canonicalisation, key construction, or volatile-param stripping silently break, the symptom is a slow rise in distinct cache keys: yesterday 200k unique keys, today 800k, tomorrow 4M. Hit rate collapses gradually. By the time the on-call notices "hit rate dropped from 85% to 30%," the regression has been in production for days. Sampling key cardinality daily (HyperLogLog over the day's cache writes) and alerting on explosion catches this category of bug at the source — before it cascades into a hit-rate incident.

**Incorrect (no cardinality observability):**

```text
Day 1: hit_rate = 85%, distinct keys per day = 240k
Day 2: hit_rate = 84%, distinct keys per day = 380k  <-- nobody notices
Day 3: hit_rate = 78%, distinct keys per day = 720k
Day 4: hit_rate = 65%, distinct keys per day = 1.4M
Day 5: alert fires on hit_rate. On-call digs in, finds the bug shipped 4 days ago.
```

**Correct (HLL-sampled cardinality, daily, alerts on drift):**

```typescript
// On every cache.set, add the key to a daily HyperLogLog sketch
// (HLL has ~1% error at 12 KB memory, exact enough for cardinality tracking)
async function cacheSet(key: string, value: unknown, ttl: number, keyClass: KeyClass) {
  const dayBucket = new Date().toISOString().slice(0, 10);  // YYYY-MM-DD
  await redis.multi()
    .set(key, JSON.stringify(value), 'EX', ttl)
    .pfadd(`hll:cache-writes:${keyClass}:${dayBucket}`, key)  // PFADD = Redis HLL
    .expire(`hll:cache-writes:${keyClass}:${dayBucket}`, 14 * 86400)  // keep 14 days
    .exec();
}

// Daily aggregation (cron at 23:55):
//   for each keyClass:
//     cardinality_today = PFCOUNT hll:cache-writes:{class}:{today}
//     cardinality_7d_median = median of last 7 days
//     ratio = cardinality_today / cardinality_7d_median
//
//   if ratio > 1.5: alert "Key cardinality up 50% for {class}"
//   if ratio < 0.5: alert "Key cardinality down 50% for {class}"
//                   (could indicate cache being bypassed or canonicalisation
//                    over-collapsing different requests into the same key)
```

**Per-keyClass cardinality:** aggregate cardinality hides per-class spikes. A breakdown by `keyClass` reveals which path regressed. `search-anon` cardinality should match `distinct_canonical_queries × locales` — if it's 10× higher, your canonicalisation is leaking.

**Cardinality vs working set:** these are different metrics.
- **Cardinality**: total distinct keys written in a window (HLL on writes)
- **Working set**: distinct keys that account for 95% of reads (heavier to measure; often approximated by sampling)

A growing cardinality with stable working set means you're writing more keys that are never read again — wasted cache writes. A growing working set with stable cardinality means the same keys are getting more reads — good.

**The "single-key explosion" failure mode:** suppose someone adds `Date.now()` to a key by accident. Cardinality explodes by request rate × time. The HLL catches this within a day. Without it, hit rate slowly degrades and the cause is harder to find.

**Companion alerts:**
- Cardinality up >50% week-over-week
- Hit rate down >10% week-over-week
- Cache memory usage approaching limit (90%) — if working set has grown legitimately, time to up-size

**OpenSearch parallel:** if you're using OpenSearch's own request cache or shard request cache, track the number of cached requests per shard. Spikes indicate a canonicalisation issue at the application layer that's bypassing the cache too.

**Cost of HLL:** PFADD is ~1µs, PFCOUNT is ~10µs. Negligible per request. The 12 KB per class per day is also negligible. The instrumentation cost approaches zero.

Reference: [Redis HyperLogLog (PFADD/PFCOUNT)](https://redis.io/docs/latest/develop/data-types/probabilistic/hyperloglogs/) · [HLL paper — Flajolet et al. 2007](https://stefanheule.com/papers/edbt2013-hyperloglog.pdf)
