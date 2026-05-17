---
title: Precompute the Popular Fraction with Batch Jobs
impact: HIGH
impactDescription: serves 40-60% of traffic from precomputed cache at near-zero per-request cost
tags: strat, batch, precompute, head-of-distribution, schedule
---

## Precompute the Popular Fraction with Batch Jobs

In Zipf-distributed traffic, a small set of popular queries/recommenders accounts for the majority of requests (top 100 search queries often serve 30-50% of traffic; top 1000 cohort × surface combinations cover 80% of recommender calls). These are *predictable*: yesterday's top queries are highly correlated with today's. Precomputing this set in a batch job — once or twice a day — and writing directly to the cache means the head of the distribution serves from cache *before any user requests it*. The long tail still uses cache-aside, but you avoid the cold-miss spike on the highest-leverage keys.

**Incorrect (always cache-aside — every popular query pays the cold-miss cost once per TTL):**

```typescript
// Day starts at 06:00. Cache from yesterday has expired or been evicted.
// First 1000 requests for "pizza near me" all miss simultaneously.
// OpenSearch sees a thundering herd; the 1001st request finally hits cache.

async function search(q: string, ctx: Ctx) {
  const key = buildKey(q, ctx);
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  const fresh = await opensearch.search(buildQuery(q, ctx));
  await redis.set(key, JSON.stringify(fresh), 'EX', 1800);
  return fresh;
}
```

**Correct (nightly batch warms the top of the distribution):**

```python
# scripts/precompute_popular_searches.py — runs at 05:30 daily
import boto3, json, redis

r = redis.from_url('rediss://...')
opensearch = boto3.client('opensearch')

# 1. Load yesterday's top queries from the access log
top_queries = load_from_s3('s3://cache-analytics/top-queries-yesterday.json')
# Format: [{"query": "...", "filters": {...}, "locale": "...", "hits": 12345}, ...]
# Take top 5000 across all locales

# 2. For each, execute the OpenSearch query and write to cache
for q in top_queries[:5000]:
    cache_key = build_cache_key(q['query'], q['filters'], q['locale'])
    result = opensearch.search(body=build_query(q['query'], q['filters'], q['locale']))
    # TTL: 24h + small jitter, so they don't all expire simultaneously
    ttl = 86400 + (hash(cache_key) % 600)
    r.set(cache_key, json.dumps(result), ex=ttl)

# Cost: 5000 OpenSearch queries spread over 30 minutes (avoid clustering)
# Benefit: at 06:00 traffic ramp-up, the head of the distribution serves
#          ~50% of requests from cache with zero cold-miss spikes.
```

**Combine with cache-aside for the long tail:**

```typescript
// Application code is unchanged — cache-aside still serves both head and tail.
// The batch job populated the head; the tail populates itself lazily.
async function search(q: string, ctx: Ctx) {
  const key = buildKey(q, ctx);
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);  // 50%+ of traffic hits here, populated by batch
  const fresh = await opensearch.search(buildQuery(q, ctx));
  await redis.set(key, JSON.stringify(fresh), 'EX', 1800);
  return fresh;
}
```

**When to re-run the batch:**
- Daily for stable distributions (most marketplaces)
- Hourly for time-sensitive surfaces ("now trending", live events, sports scores)
- After any catalog or model update that meaningfully changes top results (synonym table refresh, search-relevance model deploy)

**Top-K source:**
1. **Real query log** for search — last-7-day rolling top-1000 by hit count, dedup'd by canonical form
2. **Real cohort × surface log** for recommenders — last-day top combinations
3. **Hand-curated** for known marketing moments (Black Friday queries, holiday gift guides) — overlay onto data-driven top-K

**Validation:** measure `precomputed_keys_hit_in_first_hour / precomputed_keys_total`. If <50%, your top-K predictor is poorly calibrated — likely because the distribution shifted (seasonality, new ad campaign). Recompute the seed set more frequently.

**Personalize variant:** the cohort precomputation in [pers-cohort-precomputation](pers-cohort-precomputation.md) is the same pattern applied to recommenders — precompute per (cohort × surface), then cache-aside the long tail of less-common cohorts.

Reference: [Netflix: How Netflix Warms Petabytes of Cache Data](https://blog.bytebytego.com/p/how-netflix-warms-petabytes-of-cache) · [Pinterest: Scaling Cache Infrastructure](https://stackshare.io/pinterest/scaling-cache-infrastructure-at-pinterest)
