---
title: Store Geohashes as Sorted Strings for Prefix Range Scans
impact: MEDIUM-HIGH
impactDescription: prevents full scans; proximity becomes a range scan
tags: idx, range-scan, prefix, btree, sorted
---

## Store Geohashes as Sorted Strings for Prefix Range Scans

A geohash's great property as a key is that lexicographic string order follows spatial proximity within a region — all points in a cell share a prefix and sort contiguously. Stored in a B-tree-indexed string column, "everything in region R" is a single range scan (`>= R AND < R⁺`), not a full table scan. Storing the hash unindexed, or only as separate lat/lon columns, throws this away and forces scan-and-filter.

**Incorrect (separate columns, full scan with bounds):**

```typescript
// No geohash key; every proximity query scans and filters on two columns.
await db.query(
  "SELECT * FROM places WHERE lat BETWEEN $1 AND $2 AND lon BETWEEN $3 AND $4",
  [latMin, latMax, lonMin, lonMax], // no single index serves both ranges well
);
```

**Correct (indexed geohash column, prefix range scan):**

```sql
CREATE TABLE places (id bigint, geohash text);
CREATE INDEX places_geohash_idx ON places (geohash); -- B-tree
```

```typescript
// Region prefix -> contiguous half-open range. Increment the last char for the upper bound.
function upperBound(prefix: string): string {
  const last = prefix.charCodeAt(prefix.length - 1);
  return prefix.slice(0, -1) + String.fromCharCode(last + 1);
}
await db.query(
  "SELECT * FROM places WHERE geohash >= $1 AND geohash < $2",
  [prefix, upperBound(prefix)],
);
```

For multi-cell proximity, run one range per cell in the 3×3 block ([[qry-search-cell-plus-neighbors]]) or per covering range ([[qry-bbox-range-decomposition]]).

**When NOT to apply:**
- If your store has native geospatial indexing (PostGIS `GEOGRAPHY` + GiST, MongoDB `2dsphere`), prefer it — it handles curvature and true distance directly. Geohash-as-string shines in plain key-value or relational stores without geo support.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash); [Use The Index, Luke](https://use-the-index-luke.com/)
