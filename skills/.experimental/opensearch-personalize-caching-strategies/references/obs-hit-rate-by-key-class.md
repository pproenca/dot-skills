---
title: Track Hit Rate by Key Class, Never Aggregate Only
impact: HIGH
impactDescription: aggregate hit rate hides 5-50% per-class variance
tags: obs, hit-rate, dimensionality, key-class, dashboards
---

## Track Hit Rate by Key Class, Never Aggregate Only

An aggregate "85% hit rate" dashboard is almost useless for debugging or capacity planning. The number hides the components: search-anonymous (95%) and search-logged-in (40%) and recommender-popular (98%) all roll up to the same single line. A regression in any one of these can be masked by the others. The fix is to slice hit rate by **key class** — a coarse categorisation of cache traffic (typically 5-15 classes) reported as separate metrics. Drift in any class is visible immediately, capacity planning is per-class, and incidents have a starting point.

**Incorrect (one global hit-rate metric):**

```typescript
// Single counter — hides all the interesting variance
async function cacheGet(key: string, fetch: () => Promise<unknown>) {
  const cached = await redis.get(key);
  if (cached) {
    metrics.increment('cache.hit');     // just "hit"
    return JSON.parse(cached);
  }
  metrics.increment('cache.miss');
  const fresh = await fetch();
  await redis.set(key, JSON.stringify(fresh), 'EX', 600);
  return fresh;
}

// Dashboard:
//   cache_hit_rate = hits / (hits + misses) = 85%   <-- this is all you see
// Reality:
//   search-anon:      95% (good)
//   search-loggedin:  40% (bad — regression yesterday)
//   recommender-pop:  98% (good)
//   recommender-pers: 30% (always bad — but no one notices the regression in search)
```

**Correct (tag every cache event with the key class):**

```typescript
type KeyClass =
  | 'search-anon'
  | 'search-loggedin'
  | 'search-candidates'
  | 'recommender-popular'
  | 'recommender-cohort'
  | 'listing-direct'
  | 'user-profile'
  | 'session-vector'
  | 'feature-flag';

async function cacheGet<T>(
  key: string,
  keyClass: KeyClass,
  fetch: () => Promise<T>,
): Promise<T> {
  const cached = await redis.get(key);
  if (cached) {
    metrics.increment('cache.hit', { keyClass });
    return JSON.parse(cached);
  }
  metrics.increment('cache.miss', { keyClass });
  const fresh = await fetch();
  await redis.set(key, JSON.stringify(fresh), 'EX', 600);
  return fresh;
}

// Dashboard:
//   cache_hit_rate{keyClass="search-anon"}        = 95%
//   cache_hit_rate{keyClass="search-loggedin"}    = 40%  <-- regression alert fires
//   cache_hit_rate{keyClass="recommender-popular"} = 98%
//   cache_hit_rate{keyClass="recommender-cohort"} = 75%
//   ...
```

**Per-class alert thresholds.** Each class has its own normal range and should alert on its own. `search-anon` at 70% is critical; `recommender-cohort` at 70% is fine. One global threshold can't serve both.

**Bonus dimensions to slice by:**
- **Tier** (L1, L2, origin) — see [strat-tiered-promotion](strat-tiered-promotion.md). Class × tier reveals "L1 is missing for cohort recs" vs "L2 is missing."
- **Locale** — sometimes a locale-specific config bug collapses hit rate just in one country.
- **A/B treatment** — if a treatment changes the cache key shape, hit rate per arm differs; useful for comparing arms beyond user-facing metrics.

**Cardinality budget:** keep the total `keyClass × tier × locale × treatment` dimension count under ~1000. Metrics backends bill on series count. Drop the dimensions that don't move the dashboard.

**Per-key hit rate is too granular.** You don't want a metric per cache key (millions of series). The class is the right grain — small enough to alert on, large enough to be meaningful.

**Validation:** at deploy time, compare hit-rate-by-class before/after. Major drops indicate the deploy changed key construction (canonicalisation regression, version leak). Catch these before they hit aggregate dashboards.

Reference: [Pinterest: cache observability by key prefix](https://stackshare.io/pinterest/scaling-cache-infrastructure-at-pinterest) · [Twitter Twemcache stats](https://blog.x.com/engineering/en_us/a/2012/caching-with-twemcache)
