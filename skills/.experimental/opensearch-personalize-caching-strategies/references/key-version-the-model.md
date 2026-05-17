---
title: Include the Personalize Solution Version in the Cache Key
impact: CRITICAL
impactDescription: prevents serving stale recommendations for hours after retrain
tags: key, version, personalize, solution-version, invalidation
---

## Include the Personalize Solution Version in the Cache Key

A Personalize recommender is bound to a *solution version* (the trained model). When the model retrains — nightly, weekly, or on demand — the campaign points to a new solutionVersionArn, and the old recommendations are no longer the output of the active model. If your cache key doesn't include the solution version, you keep serving last-week's recommendations until the TTL expires. The retrain happened, the dashboards say "active model: v42", and users see results from v41 for the cached duration. Including the solution version in the key makes the cache self-invalidate on retrain — old entries become orphan, new ones start fresh.

**Incorrect (cache key independent of model version):**

```typescript
const KEY = (cohort: string, locale: string) => `homepage:${cohort}:${locale}`;

async function getRecs(cohort: string, locale: string, userId: string) {
  const cached = await redis.get(KEY(cohort, locale));
  if (cached) return JSON.parse(cached);
  const fresh = await personalize.getRecommendations({
    campaignArn: HOMEPAGE_CAMPAIGN,
    userId,
  });
  await redis.set(KEY(cohort, locale), JSON.stringify(fresh), 'EX', 3600);
  return fresh;
}

// 02:00 UTC: nightly retrain finishes, campaign now points to solutionVersion v43.
// 02:00-03:00 UTC: 50% of traffic continues to hit cache entries from v42.
// Some users get v42 recs, some v43. Mixed treatment, untrackable in A/B logs.
```

**Correct (solution version baked into the key):**

```typescript
// Subscribe to Personalize campaign updates (EventBridge or a polling refresher).
// Maintain an in-memory copy of the active solution version per campaign.
let ACTIVE_SOLUTION_VERSION = await fetchActiveSolutionVersion(HOMEPAGE_CAMPAIGN);

setInterval(async () => {
  ACTIVE_SOLUTION_VERSION = await fetchActiveSolutionVersion(HOMEPAGE_CAMPAIGN);
}, 30_000);  // 30s drift acceptable

// Short hash of the ARN — keeps keys compact while uniquely identifying the version
const versionTag = (arn: string) => createHash('sha1').update(arn).digest('hex').slice(0, 8);

const KEY = (cohort: string, locale: string) =>
  `homepage:${cohort}:${locale}:v${versionTag(ACTIVE_SOLUTION_VERSION)}`;

async function getRecs(cohort: string, locale: string, userId: string) {
  const cached = await redis.get(KEY(cohort, locale));
  if (cached) return JSON.parse(cached);
  const fresh = await personalize.getRecommendations({
    campaignArn: HOMEPAGE_CAMPAIGN,
    userId,
  });
  await redis.set(KEY(cohort, locale), JSON.stringify(fresh), 'EX', 3600);
  return fresh;
}

// 02:00 UTC: retrain finishes, active version becomes v43.
// New keys: homepage:c1:en-gb:v8a3c1e9f  (the new versionTag)
// Old keys: homepage:c1:en-gb:v2f9d3e07  — never read again, evict on TTL.
// Every request after 02:00 hits the new model's outputs cleanly.
```

**Apply the same pattern to OpenSearch retrieval pipelines:** if your search pipeline includes a learning-to-rank model, your reranker model version, or a query-expansion table version, include them in the key. The principle: any artifact whose change should invalidate the cache belongs in the key, not in the cache value.

**A/B testing variant:** when running an A/B test that swaps solution versions per user bucket, key includes both the bucket and the version: `homepage:c1:en-gb:bucket-${bucket}:v${versionTag}`. This naturally segregates the two treatments' caches.

**Trade-off — at retrain, hit rate temporarily drops to 0.** This is correct behaviour; the cost is one period of full origin traffic. If retrains are frequent (hourly) and origin TPS is the bottleneck, mitigate with [strat-async-warm-up](strat-async-warm-up.md) immediately after retrain.

Reference: [Personalize: Deploying a solution version with a campaign](https://docs.aws.amazon.com/personalize/latest/dg/campaigns.html) · [Personalize EventBridge events](https://docs.aws.amazon.com/personalize/latest/dg/eventbridge.html)
