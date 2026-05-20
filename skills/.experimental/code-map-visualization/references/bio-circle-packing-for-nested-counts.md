---
title: Pack Files as Nested Circles to Show Hierarchy and Counts
impact: MEDIUM
impactDescription: prevents losing hierarchy in a flat scatter
tags: bio, circle-packing, hierarchy, d3-hierarchy, counts
---

## Pack Files as Nested Circles to Show Hierarchy and Counts

When the goal is showing how many files a module holds and how modules nest — rather than a space-filling map — pack each group's children as tangent circles inside their parent, the way cells cluster into tissue. The front-chain packing algorithm (Wang et al., the basis of d3's pack layout) makes containment and relative counts immediately legible, and the gaps between circles are what reveal the grouping. Size circles by area so counts read correctly ([[encode-size-by-area-not-radius]]).

**Incorrect (a flat scatter of equal dots):**

```typescript
files.forEach((f) => drawCircle(ctx, f.xy, 4, domainColor(f.domain))); // hierarchy and counts invisible
```

**Correct (nested tangent circles expose hierarchy and per-group counts):**

```typescript
const root = hierarchy(moduleTree).sum((d) => d.loc);          // area encodes size
pack<ModuleNode>().size([w, h]).padding(3)(root);
root.descendants().forEach((n) => drawCircle(ctx, [n.x, n.y], n.r, domainColor(n.data.domain)));
```

**When NOT to apply:**
- Circle packing wastes the inter-circle space and breaks spatial adjacency — if regional proximity from the projection matters, use Voronoi tessellation ([[bio-voronoi-regions-for-space-filling-tessellation]]) instead.

Reference: [Wang et al. — Visualization of Large Hierarchical Data by Circle Packing](https://dl.acm.org/doi/10.1145/1124772.1124851); [d3-hierarchy: pack](https://d3js.org/d3-hierarchy/pack)
