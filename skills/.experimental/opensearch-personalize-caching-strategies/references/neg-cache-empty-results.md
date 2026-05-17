---
title: Cache Empty Search Results With a Short TTL
impact: MEDIUM-HIGH
impactDescription: prevents repeated empty-query CPU on OpenSearch
tags: neg, empty, opensearch, cpu, negative-cache
---

## Cache Empty Search Results With a Short TTL

An empty search result still consumes OpenSearch CPU. The cluster runs the same query, traverses indexes, applies filters, computes scores — only to return zero hits. For a misspelled long-tail query that's not going viral, this is fine. For a *common* query that returns zero hits (a category page with no inventory, a stale ad linking to a removed listing, a slug-not-found page), repeated empty-result queries can dominate cluster CPU. Cache the "zero results" response like any other — with a deliberately shorter TTL than the positive cache, because empty results often resolve when new inventory arrives.

**Incorrect (empty results bypass the cache or get long TTLs):**

```typescript
async function search(q: string, ctx: Ctx) {
  const key = buildKey(q, ctx);
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  const result = await opensearch.search(buildQuery(q, ctx));

  if (result.hits.total === 0) {
    // Some teams: don't cache empty results
    return result;  // every empty-result request hits OpenSearch
  }

  await redis.set(key, JSON.stringify(result), 'EX', 600);
  return result;
}
// Symptom: OpenSearch CPU dominated by zero-result queries from broken links,
//          misconfigured categories, or removed listings.
```

**Correct (cache empties with a short TTL):**

```typescript
async function search(q: string, ctx: Ctx) {
  const key = buildKey(q, ctx);
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  const result = await opensearch.search(buildQuery(q, ctx));

  // Cache positive AND negative — different TTLs reflect their volatility
  const ttl = result.hits.total === 0 ? 60 : 600;
  await redis.set(key, JSON.stringify(result), 'EX', ttl);
  return result;
}
// Empty results cached for 60s. The 100th query for the broken-link slug
// is served from cache. OpenSearch CPU drops accordingly.
```

**Why a shorter TTL on empties:**
- Inventory frequently arrives (new listing, new product, restocked item). A 60s TTL on empty means new inventory becomes visible quickly.
- An incorrect empty (e.g. an index bug, a query analyzer regression) self-heals in 60s rather than 10 min.
- Empty results compress extremely well (`{"hits":{"total":0,"hits":[]}}`) so memory cost is trivial.

**Companion pattern — explicit empty signaling:**

```typescript
type CachedSearchResult = {
  isEmpty: boolean;     // explicit
  hits: SearchResult;
  cachedAt: number;
};
```

The explicit flag means application code can branch on "this is a known-empty result" without parsing the full payload — useful for fallback logic (try a broader query, suggest spelling corrections, route to "did you mean" path).

**Don't cache errors as empties.** If OpenSearch returned a 5xx, don't write a "zero results" cache entry. The next request would falsely conclude "no inventory" rather than "transient origin issue."

```typescript
try {
  const result = await opensearch.search(buildQuery(q, ctx));
  // ... cache as above
} catch (err) {
  // Don't cache the failure as zero results. Either propagate or fall back.
  throw err;
}
```

**Personalize equivalent:** Personalize doesn't typically return "zero recommendations" for a cold user (it falls back to popular items), but it can throttle or fail. See [neg-cache-throttled-personalize](neg-cache-throttled-personalize.md) — same idea, applied to throttling.

**Search-suggestion variant:** for autocomplete that frequently returns "no suggestions" for unusual prefixes ("xyz"), cache the empty result aggressively (5-min TTL) — the same prefix is re-typed often and won't change.

Reference: [Google Cloud CDN negative caching](https://cloud.google.com/cdn/docs/using-negative-caching) · [Design Gurus: Negative Caching](https://www.designgurus.io/course-play/grokking-scalable-systems-for-interviews/doc/what-is-negative-caching-and-when-should-you-cache-404-or-empty-results)
