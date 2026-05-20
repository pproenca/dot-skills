---
title: Match Query Precision to the Search Radius
impact: HIGH
impactDescription: prevents the 9-cell block being smaller than the radius
tags: qry, precision, radius, neighbors, coverage
---

## Match Query Precision to the Search Radius

The cell-plus-neighbours trick only works if a cell is about the size of your search radius. Pick a precision too fine and the 3×3 block is smaller than the radius, so points two cells away are missed; pick it too coarse and you scan a huge area and pull back thousands of candidates to filter. Choose the longest geohash whose cell is at least the radius, so the 3×3 block comfortably covers a circle of that radius.

**Incorrect (fixed precision regardless of radius):**

```typescript
function candidatesFor(lat: number, lon: number, radiusM: number) {
  const hash = encode(lat, lon, 7); // ~150 m cell — a 1 km search misses most matches
  return [hash, ...eightNeighbors(hash)];
}
```

**Correct (precision derived from the radius):**

```typescript
function candidatesFor(lat: number, lon: number, radiusM: number) {
  const len = lengthForRadius(radiusM); // coarsest cell >= radius (see prec rule)
  const hash = encode(lat, lon, len);
  return [hash, ...eightNeighbors(hash)]; // block spans ~3x the radius each way
}
```

**When NOT to apply:**
- For variable-radius queries against a fixed-precision index, query at the index precision and expand the neighbour ring (more than one cell out) instead of re-encoding.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash); [[prec-choose-from-error-radius]]
