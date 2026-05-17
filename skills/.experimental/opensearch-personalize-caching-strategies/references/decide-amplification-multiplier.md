---
title: Account for Multi-Recommender Page Amplification
impact: CRITICAL
impactDescription: 5-10x request-rate multiplier hidden by per-recommender metrics
tags: decide, fan-out, amplification, recommenders, page-load
---

## Account for Multi-Recommender Page Amplification

A typical home page renders 5-10 recommenders ("recently viewed", "trending in your category", "similar to your wishlist", "popular near you", "complete the set"). Per-recommender dashboards show 100 req/s each — but the *user* triggers all of them per page load. The actual fan-out from the user-facing service to Personalize is 5-10×, which is invisible if you only look at per-campaign TPS. Auto-scalers, alerts, and minProvisionedTPS settings tuned per-campaign all underestimate cost and overestimate available headroom by the same factor.

**Incorrect (size each campaign as if independent):**

```typescript
// Five recommenders, each campaign sized for "100 req/s peak"
// minProvisionedTPS = 100 per campaign = $864/day floor × 5 = $4320/day floor.
//
// A homepage at 100 page views/s triggers 500 Personalize calls/s.
// Each campaign hits its 100 TPS minimum — looks fine on a per-recommender dashboard.
// Aggregate cost is 5× what the team modelled.

async function renderHomepage(userId: string) {
  const [recent, trending, similar, popular, complete] = await Promise.all([
    personalize.getRecommendations({ campaignArn: RECENT, userId }),
    personalize.getRecommendations({ campaignArn: TRENDING, userId }),
    personalize.getRecommendations({ campaignArn: SIMILAR, userId }),
    personalize.getRecommendations({ campaignArn: POPULAR, userId }),
    personalize.getRecommendations({ campaignArn: COMPLETE, userId }),
  ]);
  return { recent, trending, similar, popular, complete };
}
```

**Correct (treat the page as the unit, cache at the page boundary, coalesce upstream calls):**

```typescript
// Step 1: aggregate the dashboard at the PAGE level (page_views_per_sec)
//         not per-campaign. This is the actual demand signal.
//
// Step 2: cache at the recommender output, with a single cache lookup batch.
//
// Step 3: for cold cache, coalesce shared inputs (user features, context) to
//         avoid fetching them 5x per page.

async function renderHomepage(userId: string, ctx: PageContext) {
  const cohortKey = await getCohortKey(userId);  // one lookup, not five
  const cacheKeys = RECOMMENDER_IDS.map(id => `rec:${id}:${cohortKey}:${ctx.locale}`);

  // Batch L2 lookup — one round trip for all 5 recommenders
  const cached = await redis.mget(...cacheKeys);
  const misses = cached
    .map((v, i) => v === null ? RECOMMENDER_IDS[i] : null)
    .filter(Boolean);

  // Only call Personalize for the misses
  const fresh = await Promise.all(
    misses.map(id => personalize.getRecommendations({
      campaignArn: CAMPAIGN_BY_ID[id],
      userId,
    }))
  );

  // Write-back the misses with jittered TTL (see ttl-jitter-to-prevent-thundering)
  await Promise.all(fresh.map((r, idx) =>
    redis.set(`rec:${misses[idx]}:${cohortKey}:${ctx.locale}`,
              JSON.stringify(r), 'EX', 600 + rand(0, 120))
  ));

  return assembleRecommenders(cached, fresh);
}
// At 100 page views/s with 70% per-recommender hit rate:
//   actual Personalize calls/s = 100 * 5 * 0.3 = 150  (down from 500)
//   cost reduction = 70%, infrastructure aligned with PAGE traffic, not campaign traffic.
```

**Dashboard rule:** primary metric is `personalize_calls_per_page_view`, target = `n_recommenders * (1 - hit_rate)`. If actuals exceed target by >20%, your cache key is leaking ([key-canonicalize-query](key-canonicalize-query.md)) or your cohorts are too granular ([pers-cohort-precomputation](pers-cohort-precomputation.md)).

Reference: [Pinterest: Feature Caching for Recommender Systems](https://medium.com/pinterest-engineering/feature-caching-for-recommender-systems-w-cachelib-8fb7bacc2762)
