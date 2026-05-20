---
title: Make Coordinates Reproducible and Incremental-Stable
impact: HIGH
impactDescription: prevents the whole map reshuffling on every commit
tags: map, determinism, stability, seeding, incremental
---

## Make Coordinates Reproducible and Incremental-Stable

A code map is navigable only if a file stays roughly where it was last time you looked. Layout algorithms are usually randomised — a fresh run reshuffles everything, so a file's geohash region changes commit to commit and any saved "go to region X" breaks. Fix the random seed for reproducibility, and when the codebase changes, anchor existing nodes and solve only for new or moved ones so adding one file does not relocate the rest.

**Incorrect (unseeded layout, full re-solve every run):**

```typescript
function rebuildMap(graph: ImportGraph) {
  const layout = forceDirected(graph, { seed: Math.random() }); // different every run
  return layout.positions(); // every file's geohash changes; the map is unrecognisable
}
```

**Correct (fixed seed; anchor existing nodes):**

```typescript
function rebuildMap(graph: ImportGraph, previous: Map<string, [number, number]>) {
  const layout = forceDirected(graph, {
    seed: 42,                              // reproducible across machines and runs
    fixedPositions: previous,              // existing files keep their coordinates
    solveOnly: graph.nodesNotIn(previous), // only place new/changed files
  });
  return layout.positions();
}
```

Persist the resulting coordinates so the next run can anchor against them — see [[map-persist-coordinate-sidecar]].

**When NOT to apply:**
- A one-off exploratory snapshot (rendered once, never compared) does not need incremental stability — but still seed the RNG so a teammate reproduces the same picture.

Reference: [CodeCity — Wettel & Lanza](https://wettel.github.io/codecity.html); [UMAP — random_state](https://umap-learn.readthedocs.io/en/latest/reproducibility.html)
