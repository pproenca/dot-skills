---
title: Return No Neighbour Past the Poles
impact: HIGH
impactDescription: prevents phantom cells at the top and bottom rows
tags: nbr, poles, latitude, edge-case, null-handling
---

## Return No Neighbour Past the Poles

Longitude wraps, but latitude does not — there is no cell north of the top row (90°N) or south of the bottom row (90°S). If your neighbour function fabricates one anyway (by wrapping latitude, or by the string algorithm recursing off the top), you get a hash that decodes to the wrong hemisphere and silently pollutes proximity results. A north query at the top row must return "no neighbour".

**Incorrect (latitude wraps like longitude):**

```typescript
function north(latCol: number, lonCol: number, bits: number) {
  const height = 1 << bits;
  return { latCol: (latCol + 1) % height, lonCol }; // wraps 90°N -> 90°S (wrong)
}
```

**Correct (clamp; signal "no neighbour"):**

```typescript
function north(latCol: number, lonCol: number, bits: number):
  { latCol: number; lonCol: number } | null {
  const height = 1 << bits;
  if (latCol + 1 >= height) return null; // already the top row — nothing beyond it
  return { latCol: latCol + 1, lonCol };
}
```

Callers treat `null` as "skip this direction", so the eight-neighbour set near a pole simply has fewer members — see [[nbr-eight-neighbor-set]].

**When NOT to apply:**
- Datasets that never approach the poles (most city-scale or codebase-map data) will not hit this, but the null-returning signature costs nothing and keeps the function correct everywhere.

Reference: [Wikipedia — Geohash](https://en.wikipedia.org/wiki/Geohash)
