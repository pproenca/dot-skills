---
title: Refine Geohash Candidates with True Distance
impact: HIGH
impactDescription: prevents square-corner false positives in results
tags: qry, haversine, refinement, false-positives, distance
---

## Refine Geohash Candidates with True Distance

A geohash query returns a *superset* — the 3×3 cell block is square and larger than your circular radius, so its corners include points inside the cells but outside the radius. Treat the geohash result as a cheap coarse filter, then compute the exact great-circle (haversine) distance to drop the false positives and sort by real proximity. Skip this and you return points in the wrong corner as if they were nearest.

**Incorrect (return raw cell candidates as results):**

```typescript
async function nearest(lat: number, lon: number, radiusM: number) {
  const cells = candidatesFor(lat, lon, radiusM);
  return fetchByCells(cells); // includes corner points beyond the radius, unsorted
}
```

**Correct (filter and sort by haversine distance):**

```typescript
function haversineM(a: LatLon, b: LatLon): number {
  const R = 6_371_000, toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(b.lat - a.lat), dLon = toRad(b.lon - a.lon);
  const h = Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(a.lat)) * Math.cos(toRad(b.lat)) * Math.sin(dLon / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
}

async function nearest(lat: number, lon: number, radiusM: number) {
  const candidates = await fetchByCells(candidatesFor(lat, lon, radiusM));
  return candidates
    .map((p) => ({ ...p, dist: haversineM({ lat, lon }, p) }))
    .filter((p) => p.dist <= radiusM)   // drop corner false positives
    .sort((a, b) => a.dist - b.dist);   // true nearest-first
}
```

**When NOT to apply:**
- When approximate cell-level results are acceptable (heatmaps, bucketed aggregations) the exact-distance pass is wasted work — the geohash bucket is the answer.
- On the synthetic code plane, swap haversine for plain Euclidean distance on the layout coordinates — there is no real curvature ([[map-normalize-to-geohash-domain]]).

Reference: [Haversine formula](https://en.wikipedia.org/wiki/Haversine_formula); [Redis Geospatial](https://redis.io/docs/latest/develop/data-types/geospatial/)
