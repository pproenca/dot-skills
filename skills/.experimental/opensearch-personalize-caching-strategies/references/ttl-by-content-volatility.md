---
title: Set TTL From Content Volatility, Not Engineering Convenience
impact: HIGH
impactDescription: prevents stale serves beyond product staleness SLA
tags: ttl, volatility, freshness, product
---

## Set TTL From Content Volatility, Not Engineering Convenience

Most teams pick `EX: 300` once and apply it to everything. That's wrong because TTL is a freshness-vs-hit-rate trade-off that depends on the volatility of the underlying data and the staleness tolerance of the product surface. Inventory levels change minute-to-minute and a 5-min TTL is too long; user-display-name changes once a month and 5-min is wastefully short. Set TTL from a written staleness budget per content class, then re-tune from measured stale-served rates ([obs-stale-served-ratio](obs-stale-served-ratio.md)).

**Incorrect (one TTL fits all):**

```typescript
async function cacheGet(key: string, fetch: () => Promise<unknown>) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  const fresh = await fetch();
  await redis.set(key, JSON.stringify(fresh), 'EX', 300);  // 300 for everything
  return fresh;
}
// "Inventory available" cached 5 min — sells out, users see "available" for 5 more min.
// "Static category list" cached 5 min — recomputed 50 times/min for no reason.
```

**Correct (TTL is per content class, picked from product tolerance):**

```typescript
// /lib/cache/policies.ts — the staleness budget, declared once
export const CACHE_POLICIES = {
  // Class             | TTL (s)  | Reason
  // ------------------|----------|-------
  inventory_count:        30,    // book/buy decisions; stale = bad UX
  search_results:         300,   // 5 min — re-rankable & limited inventory impact
  search_candidates:      900,   // 15 min — retrieval is broader, finer rerank
  recommender_output:     1800,  // 30 min — model output, predictable distribution
  user_favourites:        60,    // 1 min — fast read-after-write but not critical
  user_profile_display:   86400, // 1 day — display name, photo
  cohort_assignment:      3600,  // 1 hour — recomputed nightly anyway
  popularity_score:       3600,  // 1 hour — daily batch updates this
  category_taxonomy:      604800, // 7 days — edited weekly at most
  geo_location:           86400, // 1 day — IP-derived region
  feature_flag_state:     60,    // 1 min — must propagate quickly
} as const;

async function cacheGet<T>(
  key: string,
  policy: keyof typeof CACHE_POLICIES,
  fetch: () => Promise<T>
): Promise<T> {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  const fresh = await fetch();
  const ttl = CACHE_POLICIES[policy] + jitter(CACHE_POLICIES[policy]);
  await redis.set(key, JSON.stringify(fresh), 'EX', ttl);
  return fresh;
}
```

**Source the budget from product, not engineering.** The right question is "how many seconds can this be stale before a user notices?" — answered by the product owner of that surface, ideally documented in the data dictionary. Engineering's job is to implement it; the staleness budget is not an engineering concern unless engineering owns the surface.

**Don't pick TTL by "infinite shrug." Watch the dashboards:**
- Surface latency p99: rising at TTL boundaries → cache size is too small, evict + miss is the issue, not TTL
- Stale-served ratio: too high → TTL is too long for the content's actual mutation rate
- Hit rate: dropping → TTL is shorter than what users tolerate, or working set shifted

**The "operationally fast" exception:** for content that's expensive to invalidate but cheap to compute, use a short TTL (30-60s) and skip event-driven invalidation. This is the common pattern for derived/aggregated values.

**TTL bounds the consistency window.** Without event-driven invalidation, every value can be at most TTL stale. Use this when planning compliance/regulatory windows (e.g. "removed listings disappear within 60s"). If the TTL is 5 minutes and the SLA is 60s, you need event-driven invalidation ([ttl-event-driven-invalidation](ttl-event-driven-invalidation.md)).

Reference: [Cloudflare: TTL semantics](https://developers.cloudflare.com/cache/concepts/cache-behavior/) · [Fastly: Lifetime and revalidation](https://www.fastly.com/documentation/guides/concepts/edge-state/cache/stale/)
