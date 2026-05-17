---
title: Measure Stale-Served Ratio to Validate TTL Choice
impact: HIGH
impactDescription: prevents over-conservative TTLs costing 10-30pp of hit rate
tags: obs, stale, ttl, freshness, ratio
---

## Measure Stale-Served Ratio to Validate TTL Choice

TTL is a freshness-vs-hit-rate dial that most teams set once and never measure. Without observability into "how often did the user see stale data?" you have no feedback loop. The stale-served ratio — proportion of cache hits where the underlying source has changed since the cached version was written — is the empirical signal. High ratio → TTL is too long for the content's actual mutation rate; low ratio → TTL could be longer for free hit-rate gain. Measure by sampling: on a small fraction of cache hits, also fetch the origin and compare.

**Incorrect (set TTL once, no feedback):**

```typescript
// TTL = 600s. Why? "It felt about right."
async function getListing(id: string) {
  const cached = await redis.get(`listing:${id}`);
  if (cached) return JSON.parse(cached);
  const fresh = await db.getListing(id);
  await redis.set(`listing:${id}`, JSON.stringify(fresh), 'EX', 600);
  return fresh;
}
// No data on whether 600s is too long, too short, or right.
```

**Correct (sample cache hits, compare to fresh origin, emit the ratio):**

```typescript
const STALE_SAMPLE_RATE = 0.005;  // 0.5% of hits are double-checked

async function getListing(id: string) {
  const cached = await redis.get(`listing:${id}`);
  if (cached) {
    // Sampling: emit a comparison metric on a fraction of hits
    if (Math.random() < STALE_SAMPLE_RATE) {
      // Async, doesn't block the request
      checkStaleness(id, JSON.parse(cached)).catch(err =>
        log.warn('staleness check failed', err)
      );
    }
    return JSON.parse(cached);
  }
  const fresh = await db.getListing(id);
  await redis.set(`listing:${id}`, JSON.stringify(fresh), 'EX', 600);
  return fresh;
}

async function checkStaleness(id: string, cachedValue: Listing) {
  const fresh = await db.getListing(id);
  const isStale = !deepEqual(stripVolatile(cachedValue), stripVolatile(fresh));
  metrics.increment('cache.staleness.sampled', {
    keyClass: 'listing-direct',
    stale: isStale ? 'true' : 'false',
  });
  if (isStale) {
    // Optional: emit the diff for analysis
    metrics.observe('cache.staleness.field_diff', diffFields(cachedValue, fresh));
  }
}

// Dashboard:
//   stale_served_ratio{keyClass="listing-direct"} = stale / (stale + fresh)
//
// Tuning guidance:
//   < 1%:   TTL is shorter than necessary; consider increasing for hit-rate gain
//   1-5%:   sweet spot for most content
//   > 5%:   TTL too long for mutation rate; reduce or add event-driven invalidation
//   > 10%:  product-visible staleness; urgent reduction
```

**stripVolatile** before comparing: ignore fields you don't care about (last-fetched-at timestamps, computed derivations). Compare the data the user actually sees.

**Sample rate matters:**
- 0.1% of hits at 10k req/s = 10 samples/sec — solid signal within a minute
- 0.5% adds 0.5× the origin load — careful not to spike origin

**Use the sampled origin load as a side-channel "real" hit-rate check.** If `staleness.sampled` events should be roughly `total_hits × sample_rate`, but you see 2× that, something is double-sampling. Acts as a sanity check on the instrumentation.

**By-content-class tuning:** different classes have different mutation rates and different tolerance thresholds. A 5% stale ratio is unacceptable for price; a 5% stale ratio is fine for "popular trending today." Set per-class targets, not a single global one.

**Event-driven-invalidation visibility:** if you've added invalidation events ([ttl-event-driven-invalidation](ttl-event-driven-invalidation.md)), the stale ratio should drop. If it doesn't, events are getting lost or the subscriber is buggy.

**Stale-while-revalidate accounting:** decide whether SWR-served stale counts as "stale served" or not. Recommended: yes, it does. The user got stale data; the fact that a refresh is in flight doesn't change that. Separate it from cold-stale (no refresh in flight) only if you specifically care to distinguish.

Reference: [DebugBear: Understanding Stale-While-Revalidate](https://www.debugbear.com/docs/stale-while-revalidate) · [Pinterest: Cachelib HybridCache observability](https://medium.com/pinterest-engineering/feature-caching-for-recommender-systems-w-cachelib-8fb7bacc2762)
