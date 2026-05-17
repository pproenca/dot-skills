---
title: Coalesce Multi-Recommender Fan-Out Into Batched Calls
impact: HIGH
impactDescription: 5-10x latency and TPS reduction on multi-recommender pages
tags: pers, fan-out, batching, mget, recommenders
---

## Coalesce Multi-Recommender Fan-Out Into Batched Calls

A page with N recommenders naively fires N independent requests: N cache lookups, N Personalize calls on miss, N hydration calls to fetch item metadata. Each adds RTT and each can fail independently. Coalescing collapses N×3 round trips into 3 batched operations: one `MGET` for cache lookups, one batch of Personalize calls executed in parallel only for the miss subset, and one `mget` on OpenSearch for hydration. Latency drops from `N × (cache + origin + hydrate)` to roughly `cache + max(origin) + hydrate`.

**Incorrect (independent calls per recommender, sequential awaits):**

```typescript
async function renderHomepage(userId: string, ctx: Ctx) {
  // Each await blocks the next. 5 round trips serialized.
  const trending = await getRecs(userId, 'trending', ctx);
  const similar  = await getRecs(userId, 'similar',  ctx);
  const popular  = await getRecs(userId, 'popular',  ctx);
  const seasonal = await getRecs(userId, 'seasonal', ctx);
  const recently = await getRecs(userId, 'recently', ctx);
  return { trending, similar, popular, seasonal, recently };
}
// Each getRecs is: cache.get -> on miss personalize.get -> opensearch.mget
// 5 surfaces × ~3 RTT each, serialized: ~15 RTT total worst case.
```

**Slightly better (parallel awaits):**

```typescript
async function renderHomepage(userId: string, ctx: Ctx) {
  const [trending, similar, popular, seasonal, recently] = await Promise.all([
    getRecs(userId, 'trending', ctx),
    getRecs(userId, 'similar',  ctx),
    getRecs(userId, 'popular',  ctx),
    getRecs(userId, 'seasonal', ctx),
    getRecs(userId, 'recently', ctx),
  ]);
  return { trending, similar, popular, seasonal, recently };
}
// Parallel: ~3 RTT (max of the 5).
// But still 5 independent Redis GETs, 5 Personalize calls on miss, 5 mgets.
```

**Correct (batch at every layer):**

```typescript
const SURFACES = ['trending', 'similar', 'popular', 'seasonal', 'recently'] as const;

async function renderHomepage(userId: string, ctx: Ctx) {
  const cohort = await getCohortKey(userId);
  const keys = SURFACES.map(s => `recs:${s}:${cohort}:${ctx.locale}:v${SOLUTION_VERSION[s]}`);

  // 1. One Redis MGET for all cache entries
  const cached = await redis.mget(...keys);

  // 2. Identify the misses; parallel Personalize for misses only
  const missIdx = cached.map((v, i) => v === null ? i : -1).filter(i => i !== -1);
  const fresh = await Promise.all(
    missIdx.map(i => personalize.getRecommendations({
      campaignArn: CAMPAIGN_FOR[SURFACES[i]],
      userId,
    }))
  );

  // 3. Write-back the misses in one pipeline
  if (fresh.length > 0) {
    const pipe = redis.pipeline();
    fresh.forEach((r, idx) => {
      const i = missIdx[idx];
      pipe.set(keys[i], JSON.stringify(r), 'EX', 1800 + Math.floor(Math.random() * 300));
    });
    await pipe.exec();
  }

  // 4. Collect all the item IDs that need hydration across all surfaces
  const allItemIds = new Set<string>();
  for (let i = 0; i < SURFACES.length; i++) {
    const recs = cached[i] !== null ? JSON.parse(cached[i]!) : fresh[missIdx.indexOf(i)];
    recs.itemList.forEach((it: { itemId: string }) => allItemIds.add(it.itemId));
  }

  // 5. One mget to OpenSearch for ALL items across all surfaces (with dedup)
  const items = await opensearch.mget({
    index: 'listings',
    body: { ids: [...allItemIds] },
  });
  const byId = Object.fromEntries(items.docs.map(d => [d._id, d._source]));

  // 6. Assemble the response — each surface's items hydrated from the single mget
  return Object.fromEntries(
    SURFACES.map((s, i) => {
      const recs = cached[i] !== null ? JSON.parse(cached[i]!) : fresh[missIdx.indexOf(i)];
      return [s, recs.itemList.map((it: { itemId: string }) => byId[it.itemId])];
    })
  );
}

// Round trips: 1 MGET + max(K Personalize calls in parallel) + 1 pipeline SET + 1 mget = ~3 RTT.
// At 70% hit rate per surface, expected Personalize calls per page = 5 * 0.3 = 1.5.
// Total saved: 70%+ Personalize TPS, 80%+ OpenSearch calls (via dedup).
```

**The dedup win:** across recommenders on the same page, items repeat — the same listing might appear in "trending" and "popular near you." Hydrating items into a `Set` before the mget eliminates the duplicate fetches.

**The all-or-nothing trap:** do NOT make the page fail when one Personalize call fails. Each campaign should fail-soft to the cohort's last-known-good (see [neg-cache-throttled-personalize](neg-cache-throttled-personalize.md)) or to the popularity recommender ([pers-cold-start-cache-priority](pers-cold-start-cache-priority.md)).

**SSR consideration:** when this runs on the server (Next.js / Remix), batch across recommenders that the page will render. When it runs on the client (CSR), the same coalescing applies at the application layer (a single backend-for-frontend endpoint that batches).

Reference: [Pinterest: Feature Caching for Recommender Systems (CacheLib)](https://medium.com/pinterest-engineering/feature-caching-for-recommender-systems-w-cachelib-8fb7bacc2762) · [DataLoader pattern for batched reads](https://github.com/graphql/dataloader)
