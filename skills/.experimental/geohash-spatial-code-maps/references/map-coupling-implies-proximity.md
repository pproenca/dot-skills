---
title: Validate That Coupled Code Lands in the Same Region
impact: HIGH
impactDescription: prevents incoherent regions that mix unrelated domains
tags: map, invariant, coupling, cohesion, validation
---

## Validate That Coupled Code Lands in the Same Region

The whole value of a code map is that a geohash prefix selects a cohesive set of files — a domain or feature. That holds only if the projection keeps coupled files spatially close. This is an *invariant to measure*, not a hope: after building the map, check that files sharing a prefix are more coupled to each other than to files outside it. If they are not, the projection (or its parameters) is wrong and the map will mislead more than it helps.

**Incorrect (assume the projection worked):**

```typescript
const map = projectCodebase(graph);
shipMap(map); // no check that prefixes correspond to real domains
```

**Correct (measure intra- vs inter-region coupling):**

```typescript
function regionCohesion(map: CodeMap, prefixLen: number, graph: ImportGraph): number {
  let intra = 0, inter = 0;
  for (const [pair, weight] of graph.edges()) {
    const sameRegion =
      map.geohash(pair.a).slice(0, prefixLen) === map.geohash(pair.b).slice(0, prefixLen);
    if (sameRegion) intra += weight; else inter += weight;
  }
  return intra / (intra + inter); // ~1.0 = cohesive regions; ~0.5 = projection failed
}

if (regionCohesion(map, 4, graph) < 0.7) {
  throw new Error("projection does not preserve coupling — retune the layout before shipping");
}
```

**When NOT to apply:**
- An intentionally non-semantic map (e.g. files laid out by directory for a file-tree view) does not need this invariant — but then a geohash prefix is just a directory and the spatial framing adds little.

Reference: [CodeCity — Wettel & Lanza](https://wettel.github.io/codecity.html); [Coupling and cohesion](https://en.wikipedia.org/wiki/Coupling_(computer_programming))
