---
title: Cache Candidate Sets for Search, Full Payloads for Personalize
impact: CRITICAL
impactDescription: 2-3x storage savings and faster invalidation by caching at the right grain
tags: decide, search, personalize, grain, candidate-set
---

## Cache Candidate Sets for Search, Full Payloads for Personalize

Search and Personalize have asymmetric cache shapes. Search results are often re-rankable: the candidate set (top-200 listings from BM25 + kNN retrieval) is stable for a given query, but the final order depends on user signals, A/B treatment, and rerank model version. Cache the **candidate set** (just IDs + retrieval scores), re-rank on every request. Personalize, in contrast, returns an opaque ranked list — the model has already incorporated the user; you cannot re-rank without calling it again. Cache the **full payload**, accept that the cache invalidates on every model retrain. Treating these the same wastes 2-3× cache storage on one side or destroys reusability on the other.

**Incorrect (cache final-rendered search results, cache only IDs from Personalize):**

```typescript
// Search: cache the fully-rendered, fully-personalized result — bad
async function search(q: string, userId: string) {
  const key = `search:${q}:${userId}`;     // <- user in the key, low hit rate
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);   // ^ full hydrated response, 80KB
  const result = await opensearch.search(buildPersonalisedQuery(q, userId));
  await redis.set(key, JSON.stringify(result), 'EX', 300);
  return result;
}

// Personalize: cache only the ID list — bad
async function getRecs(userId: string) {
  const key = `recs:${userId}`;
  const ids = await redis.get(key);
  if (ids) {
    // Hydrate from OpenSearch on every hit — adds N extra calls per request
    return opensearch.mget({ index: 'listings', body: { ids: JSON.parse(ids) } });
  }
  const fresh = await personalize.getRecommendations({ userId });
  await redis.set(key, JSON.stringify(fresh.itemList.map(i => i.itemId)), 'EX', 300);
  return opensearch.mget({ index: 'listings', body: { ids: fresh.itemList.map(i => i.itemId) } });
}
```

**Correct (cache the right grain for each backend):**

```typescript
// Search: cache the CANDIDATE SET only, re-rank per request
async function search(q: string, userId: string) {
  const candidateKey = `search-candidates:${canonicalize(q)}`;  // <- user OUT of key
  let candidates = await redis.get(candidateKey);
  if (!candidates) {
    candidates = await opensearch.search(buildRetrievalOnlyQuery(q));  // top-200 IDs + scores
    await redis.set(candidateKey, JSON.stringify(candidates), 'EX', 300);
  } else {
    candidates = JSON.parse(candidates);
  }

  // Re-rank with current user signals, A/B treatment, rerank model version
  return rerank(candidates, await getUserFeatures(userId), getABTreatment(userId));
}
// Effect: shared candidate cache hits ~80% across users for the same query;
//         personalisation still applied per-request without an OpenSearch call.

// Personalize: cache FULL PAYLOAD with full hydration
async function getRecs(userId: string, surface: string) {
  const cohortKey = await getCohortKey(userId);
  const key = `recs:${surface}:${cohortKey}:${SOLUTION_VERSION}`;
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);  // fully hydrated, ready to render
  const fresh = await personalize.getRecommendations({ userId });
  const hydrated = await hydrateItems(fresh.itemList);  // one batched mget per cohort
  await redis.set(key, JSON.stringify(hydrated), 'EX', 1800);
  return hydrated;
}
// Effect: one Personalize call + one mget per cohort per 30min, not per user per request.
```

**Why the asymmetry exists:**

| Concern | Search | Personalize |
|---------|--------|-------------|
| Result order depends on | Query + retrieval + rerank model | Pre-trained model bound to userId/cohort |
| Per-user reusability of cache | Low if user in key, high if just candidate set | Low (model has already personalised) |
| Invalidation trigger | New documents, query expansion table changes | Solution version (model retrain) |
| Cost per call | OpenSearch CPU | Personalize $ + TPS |
| Right grain to cache | Candidate IDs + retrieval scores | Full ranked payload + hydrated metadata |

Reference: [OpenSearch search-pipelines for rerank](https://docs.opensearch.org/latest/search-plugins/search-pipelines/index/) · [Personalize Getting recommendations](https://docs.aws.amazon.com/personalize/latest/dg/getting-recommendations.html)
