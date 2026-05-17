---
title: Use Cache-Aside as the Default Strategy for Read-Heavy Paths
impact: HIGH
impactDescription: prevents inconsistency from ad-hoc mixed-strategy invalidation
tags: strat, cache-aside, lazy-loading, default, read-through
---

## Use Cache-Aside as the Default Strategy for Read-Heavy Paths

Cache-aside (AWS calls it "lazy loading") puts the application in control: on a read, check the cache; if miss, fetch from origin, write the result, return. Writes from the application invalidate or update the cache explicitly. This is the default for search and recommendation paths because (a) it doesn't require the writer (the search-relevance team's data pipeline, Personalize's training) to know about the cache, (b) it self-heals — a cache failure means more origin traffic, not stale serves, (c) it works with any backend store. Other strategies (write-through, read-through, refresh-ahead) are specialisations applied where cache-aside's specific weakness (cold reads pay the full origin cost) matters enough to justify the added coupling.

**Incorrect (mixing read-through, write-through, and ad-hoc invalidation without a coherent pattern):**

```typescript
async function search(q: string, ctx: Ctx) {
  // Custom read-through wrapping the cache library — but writes elsewhere
  // bypass it. No consistent invalidation story.
  return cacheLib.getOrSet(`s:${q}`, () => opensearch.search(q), 600);
}

async function reindexItem(id: string) {
  // No cache invalidation here. Stale entries linger until TTL.
  await opensearch.index({ id, ... });
}

async function bulkUpdate(ids: string[]) {
  // Tries to invalidate, but uses a different key format than search()
  for (const id of ids) await cacheLib.delete(`item:${id}`);
  // Doesn't touch the `s:*` namespace at all.
}
// Stale-serve incidents debugged for weeks.
```

**Correct (cache-aside, application-controlled):**

```typescript
// Read path: application checks cache, falls back to origin, writes back
async function search(q: string, ctx: Ctx): Promise<SearchResult> {
  const key = buildKey(q, ctx);  // see key-canonicalize-query
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  const result = await opensearch.search(buildQuery(q, ctx));
  // Jittered TTL prevents thundering-herd expiry (see ttl-jitter-to-prevent-thundering)
  await redis.set(key, JSON.stringify(result), 'EX', 600 + Math.floor(Math.random() * 60));
  return result;
}

// Write path: explicit invalidation by the application that knows what changed
async function reindexItems(itemIds: string[]) {
  await opensearch.bulk({ ... });
  // Invalidate all search caches that *could* contain these items.
  // For broad invalidation, prefer event-driven (see ttl-event-driven-invalidation).
  await invalidateByTag(`item-touched`);
}

// The cache library has ONE entry point and ONE invalidation pattern:
//   redis.get / redis.set / redis.del — keyed via buildKey()
//   tag-based invalidation via a secondary index (or RedisSearch tags)
// No "convenient" wrappers that hide which strategy is in play.
```

**Why cache-aside beats read-through (lib-managed) for search/recs:**
1. **Decoupling:** the cache library has no idea what an OpenSearch query is. Application code knows when to retry, when to fail-soft, when to use stale, when to skip the cache entirely.
2. **Failure modes:** if Redis is down, cache-aside fails open (every request goes to origin, latency degrades but correctness preserved). Lib-managed read-through often hard-fails or returns errors.
3. **Observability:** the application can instrument `cache_lookup_outcome` per request — hit/miss/error/skipped — with full context. Lib-managed caches hide this.

**When read-through IS right:** the cache backend itself is the access layer (DAX in front of DynamoDB, ProxySQL in front of MySQL). The lib handles invalidation as a first-class concern.

**When write-through IS right:** see [strat-write-through-mutations](strat-write-through-mutations.md) — user-mutated data the user immediately re-reads.

**When refresh-ahead IS right:** see [strat-refresh-ahead-hot-keys](strat-refresh-ahead-hot-keys.md) — hot keys with predictable TTL expiry spikes.

Reference: [AWS ElastiCache caching strategies](https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/Strategies.html) · [Lazy loading in ElastiCache](https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/Strategies.html#Strategies.LazyLoading)
