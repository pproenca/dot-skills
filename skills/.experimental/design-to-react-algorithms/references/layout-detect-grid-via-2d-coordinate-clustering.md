---
title: Detect CSS Grid via 2D Coordinate Clustering with Epsilon Tolerance
impact: HIGH
impactDescription: emits grid for true MxN layouts; avoids 2-level nested flex with synthetic wrappers (which break source-to-DOM mapping)
tags: layout, css-grid, clustering, freeform-inference
---

## Detect CSS Grid via 2D Coordinate Clustering with Epsilon Tolerance

Freeform groups containing MxN equally-spaced children (icon grids, color palettes, calendar months) are CSS Grid, not nested flex. Cluster the children's X and Y *edge* coordinates with an epsilon (typically 0.5px to absorb subpixel design drift); if the cluster counts produce a clean M columns × N rows, emit `display: grid`. Falling through to 2-level nested flex requires synthetic wrapper divs that have no corresponding Sketch layer, breaking the source-to-DOM map your snapshot tests rely on.

**Algorithm:**
1. Cluster X-left edges with tolerance ε → distinct column starts.
2. Cluster Y-top edges with tolerance ε → distinct row starts.
3. If `cols × rows === children.length` (every cell occupied), it's a grid.

**Incorrect (3×3 icon grid → nested flex with phantom wrappers):**

```tsx
<div className={styles.group}>           {/* outer flex column */}
  <div className={styles.row}>           {/* PHANTOM wrapper — no Sketch source */}
    <Icon name="a" /> <Icon name="b" /> <Icon name="c" />
  </div>
  <div className={styles.row}>
    <Icon name="d" /> <Icon name="e" /> <Icon name="f" />
  </div>
  <div className={styles.row}>
    <Icon name="g" /> <Icon name="h" /> <Icon name="i" />
  </div>
</div>
```

The wrapper divs have no `do_objectID` — your snapshot-diff bisection cannot point at them when something breaks.

**Correct (cluster → grid):**

```ts
function clusterEdges(values: number[], epsilon = 0.5): number[] {
  const sorted = [...values].sort((a, b) => a - b);
  const clusters: number[] = [];
  for (const v of sorted) {
    if (clusters.length === 0 || v - clusters[clusters.length - 1] > epsilon) {
      clusters.push(v);
    }
  }
  return clusters;
}

function tryGrid(group: Group, epsilon = 0.5): CssProps | null {
  const xs = clusterEdges(group.layers.map(l => l.frame.x), epsilon);
  const ys = clusterEdges(group.layers.map(l => l.frame.y), epsilon);
  if (xs.length * ys.length !== group.layers.length) return null;  // not a full grid

  // Compute column-gap and row-gap from cluster spacing (must be uniform).
  const colGap = xs.length > 1 ? xs[1] - (xs[0] + group.layers[0].frame.width) : 0;
  const rowGap = ys.length > 1 ? ys[1] - (ys[0] + group.layers[0].frame.height) : 0;

  return {
    display: 'grid',
    gridTemplateColumns: `repeat(${xs.length}, ${group.layers[0].frame.width}px)`,
    gridTemplateRows:    `repeat(${ys.length}, ${group.layers[0].frame.height}px)`,
    columnGap: `${colGap}px`,
    rowGap: `${rowGap}px`,
  };
}
```

```tsx
<div className={styles.group}>          {/* one wrapper, one Sketch source */}
  <Icon name="a" /> <Icon name="b" /> <Icon name="c" />
  <Icon name="d" /> <Icon name="e" /> <Icon name="f" />
  <Icon name="g" /> <Icon name="h" /> <Icon name="i" />
</div>
```

**Why epsilon matters:** designers rarely align pixels exactly — a 0.3px nudge is invisible but breaks naïve equality. ε=0.5px catches subpixel drift without merging genuinely different columns. For high-DPI exports, tune to ε=1.

**When NOT to use grid:** if `cols × rows !== children.length`, the layout has holes or rowspan — fall back to flex inference or absolute. Grid is for *full* MxN grids; partial grids belong in `grid-template-areas`, which requires named regions you can rarely infer from layout alone.

Reference: [W3C CSS Grid Layout Module Level 1](https://www.w3.org/TR/css-grid-1/)
