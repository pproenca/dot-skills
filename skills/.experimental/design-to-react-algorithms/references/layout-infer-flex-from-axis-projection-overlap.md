---
title: Infer Flex from 1D Axis-Projection Overlap of Sibling Bounding Boxes
impact: CRITICAL
impactDescription: replaces absolute positioning for 60-90% of freeform groups (huge maintainability win)
tags: layout, freeform-inference, projection-clustering, flexbox
---

## Infer Flex from 1D Axis-Projection Overlap of Sibling Bounding Boxes

Not every Sketch group declares `MSImmutableFlexGroupLayout` — older files and certain workflows produce freeform groups. Falling back to `position: absolute` for all of them is a maintenance disaster (every label tweak shifts pixels everywhere). The geometric test for flexbox is **mutually exclusive axis projection**: if children's bounding boxes overlap on one axis but are disjoint on the other, they form a flex row (vertical overlap, no horizontal overlap) or flex column (vice versa). This is a 1D version of the separating-axis theorem and runs in O(n log n) per group.

**Algorithm:**
1. For each pair of sibling children, compute the projection of their frames onto the X and Y axes.
2. If *every* pair is disjoint on X and overlapping on Y → **flex row** (children laid left-to-right).
3. If *every* pair is disjoint on Y and overlapping on X → **flex column**.
4. Otherwise fall back to absolute / grid inference.

**Incorrect (every freeform group → absolute):**

```css
/* Freeform group of 3 horizontally-laid-out chips */
.group { position: relative; width: 240px; height: 24px; }
.chip-1 { position: absolute; left: 0;   top: 0; }
.chip-2 { position: absolute; left: 80;  top: 0; }
.chip-3 { position: absolute; left: 160; top: 0; }
/* Any width/content change requires manually editing 3 .left values. */
```

**Correct (projection test → flex):**

```ts
type Frame = { x: number; y: number; width: number; height: number };
const intervalsOverlap = (a: [number, number], b: [number, number]) =>
  a[0] < b[1] && b[0] < a[1];

function inferAxis(children: Frame[]): 'row' | 'column' | null {
  const xInt = (f: Frame) => [f.x, f.x + f.width] as [number, number];
  const yInt = (f: Frame) => [f.y, f.y + f.height] as [number, number];

  const allPairs = (test: (a: Frame, b: Frame) => boolean) =>
    children.every((a, i) => children.slice(i + 1).every(b => test(a, b)));

  // Row: X-disjoint for every pair, Y-overlapping for every pair.
  if (allPairs((a, b) => !intervalsOverlap(xInt(a), xInt(b))) &&
      allPairs((a, b) =>  intervalsOverlap(yInt(a), yInt(b)))) return 'row';

  if (allPairs((a, b) => !intervalsOverlap(yInt(a), yInt(b))) &&
      allPairs((a, b) =>  intervalsOverlap(xInt(a), xInt(b)))) return 'column';

  return null;
}

function emitGroupLayout(group: Group): CssProps {
  if (group.layout?._class === 'MSImmutableFlexGroupLayout') return mapFlex(group);

  const sortedChildren = [...group.layers].sort((a, b) =>
    inferAxis(group.layers) === 'row' ? a.frame.x - b.frame.x : a.frame.y - b.frame.y
  );
  group.layers = sortedChildren;  // emit in main-axis order

  const axis = inferAxis(group.layers);
  if (!axis) return inferGridOrAbsolute(group);   // see layout-detect-grid-via-2d-coordinate-clustering

  return {
    display: 'flex',
    flexDirection: axis,
    gap: `${inferGap(group, axis)}px`,             // see layout-promote-freeform-when-equal-gaps
    alignItems: inferCrossAlign(group, axis),
  };
}
```

**Why this is safe:** the projection test is a *necessary* condition for a row/column layout — if it fails, you can't lay these children out as flex even theoretically (some pair would overlap). When it passes, flex is at minimum as expressive as absolute for this geometry, and far more maintainable.

**Edge case (overlapping children):** badges that intentionally overlap their parent icon will fail the projection test — fall back to absolute for that group rather than mis-classifying.

Reference: [Separating Axis Theorem (1D form)](https://en.wikipedia.org/wiki/Hyperplane_separation_theorem)
