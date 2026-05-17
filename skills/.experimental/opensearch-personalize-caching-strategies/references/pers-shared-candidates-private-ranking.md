---
title: Cache Retrieval Candidates Globally, Re-Rank Per-User From Cache
impact: HIGH
impactDescription: 70-90% hit rate on the candidate set with per-user personalisation preserved
tags: pers, retrieval, rerank, candidates, two-stage
---

## Cache Retrieval Candidates Globally, Re-Rank Per-User From Cache

Most modern ranking pipelines are two-stage: a recall layer retrieves a few hundred candidates from billions, and a rerank layer orders the top-50 with personalised signals. The recall layer's output for a given query is identical across users — it's the rerank stage that consumes user signals. Cache the candidate set with a user-agnostic key (query × filters × locale), then run the lightweight rerank in-process on the cached candidates. This gets near-100% cross-user reuse on retrieval (the expensive part) and preserves per-user personalisation in the cheap part.

**Incorrect (cache the final personalised ranking — user_id in key, low reuse):**

```typescript
async function search(q: string, userId: string, ctx: Ctx) {
  const key = `search:${q}:${userId}:${ctx.locale}`;  // user in key
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  // Single-stage personalised query — expensive function_score over the full index
  const result = await opensearch.search({
    index: 'listings',
    body: {
      size: 50,
      query: buildPersonalisedFunctionScore(q, userId),  // 200-500ms
    },
  });
  await redis.set(key, JSON.stringify(result), 'EX', 300);
  return result;
}
// userId in the key -> hit rate ~2%. Each user re-runs the expensive query.
```

**Correct (cache candidates, re-rank per-user):**

```typescript
async function search(q: string, userId: string, ctx: Ctx) {
  // Stage 1: candidate retrieval — user-agnostic key, high reuse
  const candidates = await getCandidates(q, ctx);

  // Stage 2: per-user rerank — cheap, in-process
  const userFeatures = await getUserFeatures(userId);  // L1 cached, ~1ms
  return rerank(candidates, userFeatures, getABTreatment(userId));
}

async function getCandidates(q: string, ctx: Ctx) {
  const key = `candidates:${canonicalise(q)}:${ctx.locale}:${ctx.geoRegion}`;
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  // Retrieval-only query: BM25 + kNN + RRF, no per-user signals
  // (see opensearch-function-scoring-algorithms for the retrieval rules)
  const result = await opensearch.search({
    index: 'listings',
    body: {
      size: 200,  // wider candidate set for downstream rerank
      _source: ['id', 'features_for_rerank'],  // only fields the reranker needs
      query: buildHybridRetrievalQuery(q),
    },
  });
  const candidates = result.hits.hits.map(h => ({
    id: h._id,
    retrievalScore: h._score,
    rerankFeatures: h._source.features_for_rerank,
  }));
  await redis.set(key, JSON.stringify(candidates), 'EX', 600);
  return candidates;
}

function rerank(candidates: Candidate[], userFeatures: UserFeatures, ab: ABTreatment) {
  // Cheap in-process scorer — dot product, gradient boosting model, or rule-based
  return candidates
    .map(c => ({
      ...c,
      finalScore: c.retrievalScore * 0.4
                + dot(c.rerankFeatures.embedding, userFeatures.sessionVector) * 0.5
                + ab.featureWeight * c.rerankFeatures.boostScore,
    }))
    .sort((a, b) => b.finalScore - a.finalScore)
    .slice(0, 50);
}

// Effect:
//   getCandidates hit rate: ~85% across users for the same query
//   rerank runtime: ~2-5ms per request (200 candidates, simple math)
//   total p50: dropped from ~250ms (origin) to ~20ms (cache hit + rerank)
```

**Sizing the candidate set:** rule of thumb, candidates = 4× to 10× the displayed result count. For a 10-result first page, retrieve 50-100 candidates and rerank them. For a 50-result infinite scroll, retrieve 200-500. Larger candidate sets give rerank room to diverge per user, but increase cache payload size.

**When this pattern doesn't apply:** if your retrieval already uses per-user signals (e.g. embedding-based retrieval with a user-conditioned query tower), the candidate set IS personalised — caching it user-agnostically would corrupt results. In that case, fall back to cohort-keyed caching ([key-segment-not-user](key-segment-not-user.md)) and accept the lower hit rate.

**Companion rule:** `eval-online-offline-correlation` in the sibling skill — when you split into two stages, your offline NDCG metric must measure end-to-end (candidates → rerank), not just the retrieval stage. Otherwise you optimise the wrong half.

Reference: OpenSearch search-pipelines for two-stage [recall-multi-stage](../../opensearch-function-scoring-algorithms/references/recall-multi-stage.md) and [recall-hybrid-rrf](../../opensearch-function-scoring-algorithms/references/recall-hybrid-rrf.md) in the sibling skill · [Airbnb: Embedding-Based Retrieval](https://airbnb.tech/uncategorized/embedding-based-retrieval-for-airbnb-search/)
