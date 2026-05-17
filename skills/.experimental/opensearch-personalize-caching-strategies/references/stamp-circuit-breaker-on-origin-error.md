---
title: Trip the Circuit Breaker on Origin Errors; Fall Back to Stale
impact: HIGH
impactDescription: prevents cascade failure when OpenSearch or Personalize errors
tags: stamp, circuit-breaker, fallback, resilience, origin-failure
---

## Trip the Circuit Breaker on Origin Errors; Fall Back to Stale

When OpenSearch or Personalize starts failing — partial cluster outage, Personalize 429 throttle, slow cluster restart — uncoordinated retries from the application tier make it worse. The cache, ironically, can be the rescue: if the origin is failing, stop calling it, serve stale (or popularity fallback) until it recovers. A circuit breaker sits between the cache miss path and the origin: after N consecutive failures within a window, open the circuit (skip origin calls entirely, serve stale or fail-soft); after a cool-down, try one probe call; if it succeeds, close the circuit. Without this, a failing origin pulls down the whole service.

**Incorrect (every miss retries the origin, amplifying its load):**

```typescript
async function getRecs(key: string, userId: string) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  // Origin is failing. Every miss retries with exponential backoff.
  // 10k req/s × 4 retries each = 40k retry attempts/s on a sick origin.
  return retry(() => personalize.getRecommendations({ userId }), { attempts: 4 });
}
```

**Correct (circuit breaker + stale fallback):**

```typescript
import CircuitBreaker from 'opossum';

const breaker = new CircuitBreaker(
  (userId: string) => personalize.getRecommendations({ userId }),
  {
    errorThresholdPercentage: 50,   // open if 50% of calls fail
    resetTimeout: 30_000,            // try one probe after 30s
    rollingCountTimeout: 10_000,     // sliding window for failure-rate calc
    timeout: 2000,                   // treat >2s as failure
  }
);

// Fallback: serve stale-but-expired entry, or popularity recommender
breaker.fallback(async (userId: string, key: string) => {
  // 1. Try expired-stale entry (TTL passed, but value still in cache)
  const expired = await redis.get(`${key}:stale`);
  if (expired) {
    metrics.increment('cache.fallback', { kind: 'expired-stale' });
    return JSON.parse(expired);
  }
  // 2. Fall back to popularity recommender (OpenSearch only, no Personalize)
  metrics.increment('cache.fallback', { kind: 'popularity' });
  return getPopularityRecs(userId);
});

async function getRecs(key: string, userId: string) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  // Cache the result on the "stale" key too, so it survives TTL
  const fresh = await breaker.fire(userId, key);
  await redis.multi()
    .set(key, JSON.stringify(fresh), 'EX', 1800)
    .set(`${key}:stale`, JSON.stringify(fresh), 'EX', 86400)
    .exec();
  return fresh;
}

// During a Personalize outage:
//   First few requests fail / time out
//   Breaker opens after 50% failure rate
//   All subsequent requests bypass Personalize, return last-known-good or popularity
//   Personalize is not retried until 30-second reset window
//   When breaker probes and succeeds, normal flow resumes
```

**Key parameters:**
- **errorThresholdPercentage:** 50% is the default; lower (30%) for less-tolerant systems, higher (70%) for noisy ones
- **resetTimeout:** how long to keep the circuit open before probing. 30s is reasonable; very fast origins may want 5-10s
- **timeout:** treat slow calls as failures. Personalize p99 is typically <500ms; set timeout at 2-3× p99
- **rollingCountTimeout:** the sliding window over which failure rate is calculated

**The "stale" copy:**

```typescript
// Pattern: write the value under TWO keys
//   - main key with normal TTL (e.g. 30 min)
//   - stale key with much longer TTL (e.g. 24 h)
// Cost: 2x memory. Benefit: 24h of fallback even if origin is dead for hours.
```

For Personalize-output caching, the main key is `recs:surface:cohort:locale:v{X}` (30min TTL) and the stale key is the same with a `:stale` suffix and a 24h TTL. The fallback handler reads from `:stale` when the breaker is open.

**Alert on circuit-open.** A circuit opening means the origin is sick. Page the on-call. The circuit breaker buys time for response; it doesn't replace incident response.

**Don't trip on cache misses.** The breaker only counts origin failures. A cache miss that successfully reaches the origin is a success even if it took 200ms.

Reference: [Nygard — Release It! Circuit Breaker pattern](https://martinfowler.com/bliki/CircuitBreaker.html) · [opossum (Node.js circuit breaker)](https://nodeshift.dev/opossum/) · [Hystrix retrospective (Netflix)](https://github.com/Netflix/Hystrix)
