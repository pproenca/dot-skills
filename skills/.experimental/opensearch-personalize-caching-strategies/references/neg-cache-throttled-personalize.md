---
title: Serve Last-Known-Good When Personalize Throttles
impact: MEDIUM-HIGH
impactDescription: prevents user-visible failures during Personalize 429s
tags: neg, personalize, throttle, 429, fallback
---

## Serve Last-Known-Good When Personalize Throttles

Personalize auto-scales above minProvisionedTPS, but the scaling has a delay during which excess traffic can be throttled (HTTP 429). This is normal — it happens after deploys, traffic spikes, and during the first minutes after a campaign update. If the application propagates 429s as user-facing errors, recommendation rails go blank during these windows. The correct response is to fall back to a "last-known-good" cached value — even one beyond its TTL — rather than surfacing the throttle. Combined with the circuit breaker ([stamp-circuit-breaker-on-origin-error](stamp-circuit-breaker-on-origin-error.md)), throttles trigger a graceful degradation that's invisible to users.

**Incorrect (let 429s reach the user):**

```typescript
async function getRecs(userId: string, surface: string) {
  const key = `recs:${surface}:${userId}`;
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  try {
    return await personalize.getRecommendations({
      campaignArn: CAMPAIGN_FOR[surface],
      userId,
    });
  } catch (err) {
    // 429 propagates as a 500 to the user
    throw err;
  }
}
// Symptom: post-deploy traffic spike, Personalize 429s, frontend shows
//          "recommendations unavailable" banner. Resolves on its own in 30-60s.
```

**Correct (write a long-TTL "last-known-good" copy; fall back on 429):**

```typescript
async function getRecs(userId: string, surface: string) {
  const cohort = await getCohortKey(userId);
  const liveKey = `recs:${surface}:${cohort}:live`;
  const lkgKey  = `recs:${surface}:${cohort}:lkg`;   // last-known-good

  const cached = await redis.get(liveKey);
  if (cached) return JSON.parse(cached);

  try {
    const fresh = await personalize.getRecommendations({
      campaignArn: CAMPAIGN_FOR[surface],
      userId,
    });

    // Write to both: live (short TTL, typical cache) and LKG (long TTL, fallback only)
    await redis.multi()
      .set(liveKey, JSON.stringify(fresh), 'EX', 1800)
      .set(lkgKey,  JSON.stringify(fresh), 'EX', 86400)  // 24h
      .exec();
    return fresh;

  } catch (err) {
    if (isThrottle(err) || isTransientError(err)) {
      const lkg = await redis.get(lkgKey);
      if (lkg) {
        metrics.increment('cache.fallback.lkg_served', { surface, reason: err.code });
        return JSON.parse(lkg);
      }
      // No LKG — fall back to popularity (no personalisation but no blank)
      metrics.increment('cache.fallback.popularity', { surface });
      return getPopularityRecs(surface);
    }
    throw err;  // genuine error, not a throttle
  }
}

function isThrottle(err: unknown): boolean {
  return err?.name === 'ThrottlingException'
      || err?.$metadata?.httpStatusCode === 429
      || err?.code === 'ProvisionedThroughputExceededException';
}
```

**Live vs LKG decoupling:**
- **live** cache: normal TTL (1800s for cohort recs). Fast invalidation on retrain or content change.
- **LKG** cache: long TTL (86400s = 24h). Only read on origin failure. Long enough that an extended outage doesn't drain it.
- Cost: 2× memory for cached entries. For cohort caching (small key space) this is negligible.

**Track the LKG-served ratio.** Persistent LKG serves indicate Personalize is consistently throttled — adjust minProvisionedTPS up or reduce traffic-amplification via better cache keying ([decide-amplification-multiplier](decide-amplification-multiplier.md)).

**For OpenSearch parallel:** cluster overload (5xx, timeouts) follows the same pattern. Cache the last successful result as LKG; serve it during cluster instability. OpenSearch outages are rarer but the cost of a search outage on a marketplace is higher.

**Don't fall back to LKG for write paths.** A user submitting a search query while Personalize is throttled should get the LKG (they're reading recommendations). A user updating their preferences should NOT silently fall back — that would lose data. Mutations propagate errors normally.

**Cold-instance bootstrap:** on a new instance with empty LKG, the first throttle has nothing to serve. Mitigate by warming the LKG cache during instance startup ([strat-async-warm-up](strat-async-warm-up.md)).

Reference: [Personalize endpoints and quotas](https://docs.aws.amazon.com/personalize/latest/dg/limits.html) · [AWS SDK retry behavior for throttling](https://docs.aws.amazon.com/sdkref/latest/guide/feature-retry-behavior.html)
