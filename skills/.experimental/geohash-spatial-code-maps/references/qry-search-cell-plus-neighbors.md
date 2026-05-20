---
title: Query the Cell Plus Its Eight Neighbours, Never the Prefix Alone
impact: HIGH
impactDescription: eliminates border false negatives
tags: qry, proximity, neighbors, false-negatives, search
---

## Query the Cell Plus Its Eight Neighbours, Never the Prefix Alone

This is the defining geohash pitfall. Two points a metre apart can land in different cells when they straddle a boundary, so they share no common prefix — a search that matches only the query point's prefix silently misses them. Build the candidate set from the query cell *and its eight neighbours*, so any point within roughly one cell of the query is captured regardless of which side of a border it falls on.

**Incorrect (single prefix match):**

```typescript
async function nearby(lat: number, lon: number) {
  const hash = encode(lat, lon, 6);
  return db.query("SELECT * FROM places WHERE geohash LIKE $1", [`${hash}%`]);
  // misses every point just across a cell border from (lat, lon)
}
```

**Correct (3×3 block of cells):**

```typescript
async function nearby(lat: number, lon: number) {
  const hash = encode(lat, lon, 6);
  const cells = [hash, ...eightNeighbors(hash)]; // centre + 8 surrounding cells
  const clauses = cells.map((_, i) => `geohash LIKE $${i + 1}`).join(" OR ");
  return db.query(`SELECT * FROM places WHERE ${clauses}`, cells.map((c) => `${c}%`));
}
```

Choose the precision so one cell is about the size of the search radius ([[qry-precision-from-radius]]), then refine candidates by true distance ([[qry-refine-with-haversine]]).

**When NOT to apply:**
- Containment queries ("which region is this point in?") legitimately use a single prefix — the nine-cell expansion is specifically for proximity/radius search.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash); [Redis Geospatial](https://redis.io/docs/latest/develop/data-types/geospatial/)
