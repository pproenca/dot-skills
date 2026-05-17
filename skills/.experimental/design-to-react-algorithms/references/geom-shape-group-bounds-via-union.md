---
title: Compute shapeGroup Bounds as the Union of Children, Not Sum or First-Child
impact: HIGH
impactDescription: prevents 5-50% width/height truncation or inflation on compound shapes
tags: geom, bounding-box, shape-group, union
---

## Compute shapeGroup Bounds as the Union of Children, Not Sum or First-Child

A Sketch `shapeGroup` (or any boolean-operation container) renders as a single visual shape whose bounding box is the *union* of all child paths, not their sum and not the first child's frame. Getting this wrong produces SVG `<svg>` viewports that truncate the shape (first-child only) or pad it with empty space (sum), both of which break sibling layout that depends on the shape's visual size.

**Incorrect (first-child bounds):**

```ts
function shapeGroupSize(g: ShapeGroup) {
  return { width: g.layers[0].frame.width, height: g.layers[0].frame.height };
  // A logo built from 5 sub-shapes is now clipped to the bounds of shape #1.
}
```

**Also incorrect (sum of widths/heights):**

```ts
function shapeGroupSize(g: ShapeGroup) {
  return {
    width:  g.layers.reduce((s, l) => s + l.frame.width,  0),  // wildly inflated
    height: g.layers.reduce((s, l) => s + l.frame.height, 0),
  };
}
```

**Correct (axis-aligned union):**

```ts
function unionBounds(frames: Frame[]): Frame {
  if (frames.length === 0) return { x: 0, y: 0, width: 0, height: 0 };
  const xMin = Math.min(...frames.map(f => f.x));
  const yMin = Math.min(...frames.map(f => f.y));
  const xMax = Math.max(...frames.map(f => f.x + f.width));
  const yMax = Math.max(...frames.map(f => f.y + f.height));
  return { x: xMin, y: yMin, width: xMax - xMin, height: yMax - yMin };
}

function emitShapeGroup(g: ShapeGroup): { jsx: string; css: CssProps } {
  // Children of a shapeGroup are in shapeGroup-local coordinates.
  // The union of child frames gives the true visible extent.
  const bounds = unionBounds(g.layers.map(l => l.frame));

  // Rebase children to the union's origin so the SVG viewBox starts at 0,0.
  const rebased = g.layers.map(l => ({
    ...l,
    frame: { ...l.frame, x: l.frame.x - bounds.x, y: l.frame.y - bounds.y },
  }));

  return {
    jsx: `<svg viewBox="0 0 ${bounds.width} ${bounds.height}" width="${bounds.width}" height="${bounds.height}">
      ${rebased.map(toSvgPath).join('')}
    </svg>`,
    css: {
      // The shapeGroup's outer frame in its parent's space gets the union size.
      width:  `${bounds.width}px`,
      height: `${bounds.height}px`,
      left:   `${g.frame.x + bounds.x}px`,   // offset so visible shape lands at design position
      top:    `${g.frame.y + bounds.y}px`,
    },
  };
}
```

**Why rebasing matters for SVG:** SVG `viewBox` starts at the origin you declare. If you keep child frames in shapeGroup-local coordinates (which may start at negative values for shapes that extend beyond the parent's declared frame) without rebasing to the union, half the shape renders off-canvas.

**Sketch quirk:** for `shapeGroup` with boolean operations (`booleanOperation`: 0=union, 1=subtract, 2=intersect, 3=difference), the *visible* bounds may be smaller than the union of inputs (e.g., subtract). For exact bounds you must rasterize or use a path library — but the union is a safe upper bound that never clips the result.

Reference: [SVG 2 — coordinate systems, transformations and units](https://www.w3.org/TR/SVG2/coords.html)
