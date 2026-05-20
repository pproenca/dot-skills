---
title: Normalise to One Precision Before Comparing or Storing
impact: CRITICAL
impactDescription: prevents incorrect prefix-containment results
tags: prec, mixed-precision, prefix-matching, storage, normalization
---

## Normalise to One Precision Before Comparing or Storing

Prefix containment ("is point X inside region R?") only works when hashes are compared consistently: a region prefix against point hashes that are at least as long. Store a mix of length-6 and length-9 hashes in one index and do naive equality or prefix checks and you get wrong answers — a length-6 hash is not "inside" a length-9 hash even when it geographically contains it. Pick a storage precision, normalise on the way in, and compare regions by prefix, never by equality across lengths.

**Incorrect (equality across mixed lengths):**

```typescript
function inRegion(pointHash: string, regionHash: string): boolean {
  return pointHash === regionHash; // fails whenever the two lengths differ
}
```

**Correct (region as a prefix of a normalised point hash):**

```typescript
const STORAGE_PRECISION = 9;

function store(lat: number, lon: number): string {
  return encode(lat, lon, STORAGE_PRECISION); // every point at the same length
}

function inRegion(pointHash: string, regionPrefix: string): boolean {
  return pointHash.startsWith(regionPrefix); // region may be any shorter length
}
```

**When NOT to apply:**
- Multi-resolution indexes (deliberately storing several truncations of each hash) are a valid advanced pattern — but then each resolution lives in its own column/key and is never compared across resolutions by equality. See [[idx-sorted-string-range-scan]].

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash); [Elasticsearch geohash_grid](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-geohashgrid-aggregation.html)
