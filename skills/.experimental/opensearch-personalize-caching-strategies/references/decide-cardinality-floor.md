---
title: Skip Caching When Traffic Distribution is Flat
impact: CRITICAL
impactDescription: caching flat-distribution traffic produces <15% hit rate
tags: decide, zipf, working-set, traffic-distribution, hit-rate
---

## Skip Caching When Traffic Distribution is Flat

Web traffic follows a Zipf-like distribution: the top 1% of keys account for ~40-50% of requests, top 10% for ~80%. When this distribution holds, even a small cache delivers high hit rates. When it doesn't — for example, deep-link product pages where each URL is hit by a handful of users, or hyper-personalised recommenders where every request is unique — the working set rivals the entire keyspace and hit rate stays below 15% regardless of cache size. Breslau et al. (1999) showed this empirically across multiple web traces, and the same applies to search queries and recommender outputs.

**Incorrect (cache everything regardless of distribution):**

```typescript
// Caching every search query, including the long tail of one-off queries.
async function search(query: string, filters: Filters) {
  const key = hashKey(query, filters);
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  const result = await opensearch.search(buildQuery(query, filters));
  await redis.set(key, JSON.stringify(result), 'EX', 600);
  return result;
}
// Result: 12% hit rate because half the queries are typed once and never repeated.
// Redis fills up with single-use entries that evict the hot ones.
```

**Correct (gate caching by query-popularity threshold):**

```typescript
// Profile traffic over 7 days, identify queries seen >= N times, cache only those.
//
// Build the popularity set offline:
//   query_count >= 10 in last 7 days  -> eligible for caching
//   else                              -> bypass cache, go straight to origin

const POPULAR_QUERIES = await loadFromS3('s3://search-analytics/popular-queries-v1.bloom');
//  ^ Bloom filter of normalized-query-hashes seen >= 10 times in last 7 days
//    Refreshed nightly. ~2MB for 1M popular queries at 1% FP rate.

async function search(query: string, filters: Filters) {
  const normalized = canonicalize(query, filters);

  if (!POPULAR_QUERIES.has(normalized.queryHash)) {
    // Cold long-tail query — go to OpenSearch directly. Cache would just churn.
    return opensearch.search(buildQuery(query, filters));
  }

  const cached = await redis.get(normalized.fullKey);
  if (cached) return JSON.parse(cached);
  const result = await opensearch.search(buildQuery(query, filters));
  await redis.set(normalized.fullKey, JSON.stringify(result), 'EX', 600);
  return result;
}
// Result: hit rate on cached requests rises from 12% to 70%+ because Redis
// only holds queries that will repeat. The long tail bypasses cache entirely.
```

**How to measure distribution:**
- Plot log(rank) vs log(frequency) over 7 days of traffic — straight line = Zipf, slope = α
- α ≥ 1.0: caching is highly effective (recommender outputs for logged-in users with cohorts often hit α ~ 1.2)
- 0.7 ≤ α < 1.0: caching helps but needs careful sizing
- α < 0.7: cache the hot heads only, route the tail directly to origin

**Personalize-specific signal:** if `unique_users_per_recommender_per_hour / total_calls_per_recommender_per_hour > 0.5`, per-user caching will not work — switch to cohort caching ([pers-cohort-precomputation](pers-cohort-precomputation.md)).

Reference: [Breslau, Cao, Fan, Phillips, Shenker — Web Caching and Zipf-like Distributions (INFOCOM 1999)](https://pages.cs.wisc.edu/~cao/papers/zipf-implications.html)
