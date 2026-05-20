---
title: Choose Geohash Length from the Required Error Radius
impact: CRITICAL
impactDescription: prevents 10-100x oversized or undersized cells
tags: prec, precision, error-radius, cell-size, table
---

## Choose Geohash Length from the Required Error Radius

The most common geohash mistake is picking a length by feel ("8 looks precise enough"). Each character changes cell size by roughly 5-10x, so being one off means cells an order of magnitude too coarse (false matches) or too fine (your "nearby" query returns nothing because every point lands in its own cell). Derive the length from the coarsest cell whose error radius still satisfies the requirement.

**Incorrect (hardcoded length):**

```typescript
const PRECISION = 8; // why 8? cell is ~38m x 19m — wrong for a 2 km "nearby" search
function nearbyHash(lat: number, lon: number) {
  return encode(lat, lon, PRECISION);
}
```

**Correct (derive length from the required radius):**

```typescript
// Approximate cell half-diagonal (error radius) in metres, by geohash length 1..10.
const CELL_ERROR_METRES = [2_500_000, 630_000, 78_000, 20_000, 2_400, 610, 76, 19, 2.4, 0.6];

function lengthForRadius(metres: number): number {
  for (let len = 1; len <= CELL_ERROR_METRES.length; len++) {
    if (CELL_ERROR_METRES[len - 1] <= metres) return len;
  }
  return CELL_ERROR_METRES.length;
}

const len = lengthForRadius(2000); // 2 km search -> length 5 (~2.4 km cell), not 8
```

**When NOT to apply:**
- When an external system fixes the length for you (Redis GEO uses an internal 52-bit precision; a tile scheme may mandate length 7). Match their precision rather than computing your own.

Reference: [Wikipedia — Geohash precision table](https://en.wikipedia.org/wiki/Geohash); [Elasticsearch geohash_grid](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-geohashgrid-aggregation.html)
