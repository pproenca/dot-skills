---
title: Route Anonymous Traffic to Global Cache, Logged-in to Cohort Cache
impact: HIGH
impactDescription: 90%+ hit rate on anonymous traffic, 60-80% on logged-in
tags: pers, anonymous, logged-in, routing, hit-rate
---

## Route Anonymous Traffic to Global Cache, Logged-in to Cohort Cache

Anonymous users have no individual signal: no user history, no preferences, no session beyond the current page. Their results are determined entirely by query + locale + (optionally) IP-derived region. This is a *globally-shared* keyspace — 1M anonymous users all share a small set of cache entries. Logged-in users have individual signals but cluster into cohorts (see [key-segment-not-user](key-segment-not-user.md)). Treating both groups the same wastes the anonymous-traffic reuse and sometimes leaks personalisation into anonymous results. Split at the routing layer: anonymous → query+locale key, logged-in → cohort-aware key.

**Incorrect (one code path, user-id-keyed for both, with empty userId for anonymous):**

```typescript
async function getRecs(userId: string | null, ctx: Ctx) {
  // userId='' for anonymous — accidentally produces a single global key for ALL anonymous
  // — but it's also distinct from logged-in keys, so anonymous can't reuse logged-in caches
  // and vice versa. Worst of both worlds.
  const key = `recs:${userId ?? 'anon'}:${ctx.locale}`;
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  const fresh = await personalize.getRecommendations({ userId: userId ?? 'anon' });
  await redis.set(key, JSON.stringify(fresh), 'EX', 600);
  return fresh;
}
// Anonymous behaviour is okay-ish (one shared key per locale).
// Logged-in users get user-keyed cache with ~2% hit rate.
// The split between the two is implicit, easy to miss when changing the code.
```

**Correct (explicit split with two strategies):**

```typescript
async function getRecs(userId: string | null, ctx: Ctx, surface: string) {
  if (userId === null || ctx.isAnonymous) {
    return getAnonymousRecs(surface, ctx);
  }
  return getLoggedInRecs(userId, surface, ctx);
}

// Anonymous: global cache by surface × locale × geo-region. Very high reuse.
async function getAnonymousRecs(surface: string, ctx: Ctx) {
  const key = `anon-recs:${surface}:${ctx.locale}:${ctx.geoRegion}`;
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  // For anonymous, often the right call is POPULARITY recommender, not the
  // personalised one — Personalize cold-user behaviour returns popular anyway.
  const fresh = await getPopularityRecsFromOpenSearch(surface, ctx);
  await redis.set(key, JSON.stringify(fresh), 'EX', 3600);
  return fresh;
}

// Logged-in: cohort-aware cache + Personalize per-user fallback
async function getLoggedInRecs(userId: string, surface: string, ctx: Ctx) {
  const cohort = await getCohortKey(userId);
  const key = `user-recs:${surface}:${cohort}:${ctx.locale}:v${SOLUTION_VERSION}`;
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  const fresh = await personalize.getRecommendations({
    campaignArn: CAMPAIGN_FOR[surface],
    userId,
  });
  await redis.set(key, JSON.stringify(fresh), 'EX', 1800);
  return fresh;
}

// Hit rates:
//   Anonymous: 95%+ (a few hundred keys cover all anonymous traffic globally)
//   Logged-in: 60-80% (cohort-driven)
//   Cost: anonymous bypasses Personalize entirely; logged-in calls it 1/cohort/30min
```

**Why anonymous can skip Personalize altogether:** Personalize's cold-user behaviour is "return popular items biased toward exploration." You can replicate this from OpenSearch directly using rank_feature on listing-popularity counters, far cheaper. Save Personalize for users with actual interaction history.

**Privacy:** never serve logged-in cached entries to anonymous users. The split prevents this — anonymous never sees a key tagged with `user-recs:`. Audit: a request with no userId hitting a `user-recs:*` key is a bug.

**Geo split for anonymous:** include the geo-region (country, or country+major-city) in the anonymous key. A user in London sees different popular results than a user in São Paulo. Don't share globally across regions.

Reference: [Personalize cold user behaviour](https://docs.aws.amazon.com/personalize/latest/dg/native-recipe-new-item-USER_PERSONALIZATION.html) · OpenSearch rank_feature for popularity in [opensearch-function-scoring-algorithms](../../opensearch-function-scoring-algorithms/references/qual-rank-feature-saturation.md)
