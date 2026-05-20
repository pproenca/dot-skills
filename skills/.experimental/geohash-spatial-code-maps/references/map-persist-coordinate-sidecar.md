---
title: Persist the File-to-Geohash Assignment as a Committed Sidecar
impact: HIGH
impactDescription: prevents non-reproducible, unreviewable maps
tags: map, persistence, sidecar, reproducibility, diff
---

## Persist the File-to-Geohash Assignment as a Committed Sidecar

The coordinate assignment *is* the map. If it lives only in memory, every run can produce a different map, links rot, and nobody can review how a refactor moved code across domain boundaries. Persist `path → [x, y] → geohash` (plus the layout seed and bounds) as a committed file. Then the map is reproducible, anchorable for incremental stability ([[map-stable-coordinates]]), and a code review shows a diff of which files crossed which region boundaries.

**Incorrect (recompute in memory, nothing persisted):**

```typescript
function showMap(graph: ImportGraph) {
  const map = projectCodebase(graph); // fresh, unanchored, unreviewable
  render(map); // tomorrow's map differs; no record of how regions changed
}
```

**Correct (committed sidecar with seed and bounds):**

```typescript
interface CodeMapSidecar {
  version: 1;
  seed: number;                 // reproduces the layout
  bounds: { minX: number; maxX: number; minY: number; maxY: number };
  precision: number;
  files: Record<string, { xy: [number, number]; geohash: string }>;
}

function writeSidecar(map: CodeMap, path = "codemap.json") {
  const sidecar: CodeMapSidecar = {
    version: 1, seed: map.seed, bounds: map.bounds, precision: map.precision,
    files: Object.fromEntries(
      [...map.files()].map((f) => [f, { xy: map.xy(f), geohash: map.geohash(f) }]),
    ),
  };
  fs.writeFileSync(path, JSON.stringify(sidecar, null, 2)); // commit this file
}
```

**When NOT to apply:**
- A throwaway visualisation you never compare across time can stay in memory — but the moment two people need to see the same map, persist it.

Reference: [CodeCity — Wettel & Lanza](https://wettel.github.io/codecity.html); [Reproducible builds](https://reproducible-builds.org/)
