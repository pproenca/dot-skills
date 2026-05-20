---
title: Project Code into 2D from a Structural Signal, Not Arbitrary Layout
impact: HIGH
impactDescription: prevents random regions that group unrelated files
tags: map, projection, embedding, dependency-graph, layout
---

## Project Code into 2D from a Structural Signal, Not Arbitrary Layout

Treating a codebase like a map only works if a file's `(x, y)` position *means* something — otherwise a geohash prefix groups unrelated files and the map is decoration. Derive coordinates from a structural signal (the import/dependency graph, co-change history, or a feature/token matrix) via a layout that places related code near related code. Then a geohash prefix becomes a genuine neighbourhood. Random or alphabetical placement defeats the entire premise.

**Incorrect (arbitrary placement):**

```typescript
// Position by a hash of the path -> spatially adjacent files are unrelated.
function coordOf(path: string): [number, number] {
  const h = fnv1a(path);
  return [(h & 0xffff) / 0xffff, ((h >> 16) & 0xffff) / 0xffff];
}
```

**Correct (layout from the dependency graph):**

```typescript
// Edges = imports; a force-directed (or UMAP / t-SNE) layout pulls coupled files together.
function projectCodebase(graph: ImportGraph): Map<string, [number, number]> {
  const layout = forceDirected(graph, {
    seed: 42,            // deterministic — see map-stable-coordinates
    iterations: 500,
    attraction: (a, b) => graph.edgeWeight(a, b), // imports pull nodes together
  });
  return layout.positions(); // coupled modules end up in the same region
}
```

The invariant that makes this work — coupled code stays spatially near — must be measured, not assumed: see [[map-coupling-implies-proximity]]. (Note: UMAP and t-SNE are reproducible only with a pinned seed *and* single-threaded execution — see [[map-stable-coordinates]].)

**When NOT to apply:**
- For a small codebase (tens of files) a hand-placed or directory-tree layout is clearer than a graph projection.
- The structural-signal approach pays off once the file count exceeds what a person can hold in their head.

Reference: [CodeCity — Wettel & Lanza](https://wettel.github.io/codecity.html); [UMAP](https://umap-learn.readthedocs.io/)
