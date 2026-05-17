---
title: Bucket Continuous Filters Before Hashing
impact: CRITICAL
impactDescription: 5-20x hit rate increase on price/distance/date filters
tags: key, buckets, ranges, price-filter, geo-filter
---

## Bucket Continuous Filters Before Hashing

Continuous filters — price `min=237`, distance `max=4.3km`, date range `from=2026-05-15T14:23:11Z` — produce essentially infinite key cardinality. Two users searching for the same thing with slider-driven price filters typed `min=200` and `min=210` get two cache misses, even though the result sets overlap heavily. The fix is to bucket the continuous values *before* hashing — round prices to €50 increments, distances to 1km increments, dates to day boundaries — so logically-similar requests collide on the same key. The result is reused; the user sees the cached results filtered by the original (un-bucketed) value on the client side or by a quick post-filter on the server.

**Incorrect (full-precision filters in the key):**

```typescript
type Filters = {
  priceMin?: number;
  priceMax?: number;
  distanceKm?: number;
  checkIn?: string;   // ISO timestamp
  checkOut?: string;
};

function keyFromFilters(f: Filters): string {
  return sha256(JSON.stringify(f));
}

// User A: priceMin=200, priceMax=600, distanceKm=4.3
// User B: priceMin=210, priceMax=620, distanceKm=4.5
// Different keys, both fetch the same OpenSearch response (modulo a few entries).
// Hit rate: under 10% on filtered queries.
```

**Correct (bucket continuous filters before hashing; filter the full result post-cache):**

```typescript
function bucketise(f: Filters): Filters {
  const PRICE_BUCKET_EUR = 50;
  const DISTANCE_BUCKET_KM = 1;
  return {
    // floor() the min to the bucket below, ceil() the max to the bucket above
    // -> bucketed range contains the user's exact range
    priceMin:  f.priceMin  !== undefined ? Math.floor(f.priceMin  / PRICE_BUCKET_EUR)    * PRICE_BUCKET_EUR    : undefined,
    priceMax:  f.priceMax  !== undefined ? Math.ceil (f.priceMax  / PRICE_BUCKET_EUR)    * PRICE_BUCKET_EUR    : undefined,
    distanceKm: f.distanceKm !== undefined ? Math.ceil(f.distanceKm / DISTANCE_BUCKET_KM) * DISTANCE_BUCKET_KM : undefined,
    // Date: round to day boundary in the user's timezone
    checkIn:   f.checkIn  ? roundToLocalDay(f.checkIn,  'floor') : undefined,
    checkOut:  f.checkOut ? roundToLocalDay(f.checkOut, 'ceil')  : undefined,
  };
}

async function search(q: string, filters: Filters, ctx: Ctx) {
  const bucketed = bucketise(filters);
  const key = sha256(JSON.stringify({ q, ...bucketed, locale: ctx.locale }));
  let candidates = await redis.get(key);
  if (!candidates) {
    // Fetch the bucketed (slightly wider) range
    candidates = await opensearch.search(buildQuery(q, bucketed));
    await redis.set(key, JSON.stringify(candidates), 'EX', 300);
  } else {
    candidates = JSON.parse(candidates);
  }

  // Re-filter post-cache to the user's exact range — cheap in-process work
  return postFilter(candidates, filters);
}
// User A and B now collide on the same key. Hit rate on filtered queries
// rises from 10% to 60-80% depending on bucket size choice.
```

**Choosing bucket size:**
- Too narrow: low hit rate, defeats the purpose
- Too wide: cache returns too many entries for client-side filtering, latency/payload grows
- Rule of thumb: bucket should be ~5-10% of the typical filter range
- For prices in marketplaces: €50 for accommodation, €5 for food delivery, €10 for fashion
- For distance: 1km in urban, 5km in regional, 25km in cross-country

**Validate:** measure `cache_payload_size_after_postfilter / size_at_origin`. If < 50%, your buckets are too narrow (no reuse) or post-filtering is too aggressive (waste).

**The "exact match" exception:** equality filters like `category_id=42` are already bucketed (each integer is its own bucket). Do not artificially widen them — the user wants exactly that category.

Reference: [OpenSearch range queries](https://docs.opensearch.org/latest/query-dsl/term/range/) · [Use The Index, Luke — Filtering on bounded ranges](https://use-the-index-luke.com/sql/where-clause/the-equals-operator/searching-for-ranges)
