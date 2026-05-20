---
title: Bundle Dependency Edges Along the Hierarchy
impact: MEDIUM
impactDescription: prevents a straight-line dependency hairball
tags: bio, edge-bundling, dependencies, splines, holten
---

## Bundle Dependency Edges Along the Hierarchy

Overlaying inter-file dependencies as straight lines on the map produces an unreadable hairball the moment there are more than a few dozen. Hierarchical edge bundling (Holten, developed for software class dependencies) routes each edge as a B-spline along the path through the region hierarchy, so edges sharing a route bundle together like vascular or neural pathways — turning the hairball into a few legible flows whose thickness shows traffic. Draw the many curves efficiently with instancing ([[gpu-instance-cells-not-per-quad-draw]]) on the overlay layer ([[gpu-layer-canvas2d-over-webgl]]).

**Incorrect (a straight line per dependency):**

```typescript
deps.forEach((e) => strokeLine(ctx, node[e.from].xy, node[e.to].xy)); // hairball past ~50 edges
```

**Correct (route each edge through the hierarchy and bundle shared paths):**

```typescript
const line = lineRadial().curve(curveBundle.beta(0.85)).radius((d) => d.y).angle((d) => d.x);
bundle(deps).forEach((path) => strokePath(ctx, line(path))); // edges merge into legible bundles
```

**When NOT to apply:**
- When exact source→target pairing must stay unambiguous (auditing one dependency), bundling deforms paths and hides endpoints — show that single edge straight and highlighted instead.

Reference: [Holten — Hierarchical Edge Bundles (IEEE TVCG 2006)](https://www.cs.jhu.edu/~misha/ReadingSeminar/Papers/Holten06.pdf); [Hierarchical edge bundling — Data to Viz](https://www.data-to-viz.com/graph/edge_bundling.html)
