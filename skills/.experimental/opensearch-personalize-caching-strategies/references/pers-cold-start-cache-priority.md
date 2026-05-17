---
title: Serve Cold-Start Users From Popularity Cache, Skip Personalize
impact: HIGH
impactDescription: cuts Personalize cost on cold users by 100%, faster latency
tags: pers, cold-start, popularity, fallback, personalize
---

## Serve Cold-Start Users From Popularity Cache, Skip Personalize

A cold-start user (no interaction history) has no individual signal for Personalize to personalise on. The User-Personalization recipe will return a popular-items-with-exploration mix — which is the same thing you can serve from OpenSearch using a static popularity score, at 1/100th the cost and 1/10th the latency. Calling Personalize for cold-start users wastes TPS and adds latency for zero benefit until they have enough interactions to differentiate from the cold-start mean. The cache pattern is: cold users hit a popularity cache, warm users hit Personalize (with their own cohort caching).

**Incorrect (every user goes through Personalize, including those with zero history):**

```typescript
async function getRecs(userId: string, surface: string) {
  return personalize.getRecommendations({
    campaignArn: CAMPAIGN_FOR[surface],
    userId,  // for new users, Personalize returns popular + exploration anyway
  });
}
// New-user signup spike (e.g. ad campaign): TPS spikes, Personalize bill spikes,
// users see "popular items" anyway.
```

**Correct (route by interaction-count, only mature users get Personalize):**

```typescript
const COLD_START_THRESHOLD = 5;  // tune per product; 5 is a reasonable default

async function getRecs(userId: string, surface: string, ctx: Ctx) {
  const interactionCount = await getInteractionCount(userId);  // cached, ~1ms

  if (interactionCount < COLD_START_THRESHOLD) {
    // Cold-start path: popularity cache, no Personalize call
    return getPopularityRecs(surface, ctx);
  }

  // Warm path: cohort cache + Personalize
  return getWarmUserRecs(userId, surface, ctx);
}

async function getPopularityRecs(surface: string, ctx: Ctx) {
  const key = `pop-recs:${surface}:${ctx.locale}:${ctx.geoRegion}`;
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  // Fetch from OpenSearch with rank_feature popularity + exploration term
  // (see opensearch-function-scoring-algorithms/qual-rank-feature-saturation.md)
  const fresh = await opensearch.search({
    index: `listings-${ctx.geoRegion}`,
    body: {
      size: 50,
      query: {
        function_score: {
          query: { match_all: {} },
          functions: [
            { rank_feature: { field: 'popularity_30d', saturation: {} } },
            { random_score: { seed: Math.floor(Date.now() / 3600000) } },  // hourly rotation
          ],
          score_mode: 'sum',
        },
      },
    },
  });
  await redis.set(key, JSON.stringify(fresh), 'EX', 600);
  return fresh;
}

// Effect for a 1M-new-user signup spike:
//   Old: 1M users × 5 surfaces × 1 Personalize call/page = 5M TPS bursts
//   New: 1M users × 5 surfaces × 1 popularity cache lookup (95% hit) = 250k OS calls
//        Personalize TPS unaffected by the spike entirely.
```

**Threshold tuning:** the right `COLD_START_THRESHOLD` is the interaction count at which Personalize predictions diverge from popularity by a meaningful NDCG margin. Measure: take users at interaction-count = N, run both predictions, compute NDCG against ground-truth clicks. The threshold is the N at which Personalize NDCG > popularity NDCG by ≥5%.

**The "warm-up" promotion:** track each user's interaction count via an event-driven counter (PutEvents triggers a Redis INCR on the user's counter). When the counter crosses the threshold, the next request automatically routes to the warm path. No nightly batch needed for promotion.

**Apply equally to cold-start ITEMS:** new listings have no booking history. Their Personalize-derived recommendations are unreliable; serve them via the "similar items" surface using content-based retrieval (text embedding similarity in OpenSearch kNN) instead.

Reference: [Personalize cold user / cold item handling](https://docs.aws.amazon.com/personalize/latest/dg/native-recipe-new-item-USER_PERSONALIZATION.html) · [AWS blog: Personalize 50% better recommendations on cold items](https://aws.amazon.com/blogs/machine-learning/amazon-personalize-can-now-create-up-to-50-better-recommendations-for-fast-changing-catalogs-of-new-products-and-fresh-content/)
