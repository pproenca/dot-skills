---
title: Compose Parent Transforms Before Emitting Coordinates
impact: HIGH
impactDescription: prevents 10-1000px positioning errors when children sit inside rotated/scaled parents
tags: geom, transforms, coordinate-spaces, matrix-composition
---

## Compose Parent Transforms Before Emitting Coordinates

A Sketch layer's `frame.x, frame.y` are expressed in its parent's coordinate system, *before* any of the parent's rotation, scale, or flip. If you flatten a deeply-nested tree to absolute positions on the page without composing the chain of parent transforms, every layer below a rotated group lands in the wrong place. Walk the ancestor chain, multiply transforms in order, and apply the composed matrix when emitting absolute coordinates.

**Incorrect (concatenate raw x/y up the chain):**

```ts
function pageCoords(layer: Layer, ancestors: Layer[]): { x: number; y: number } {
  let x = layer.frame.x, y = layer.frame.y;
  for (const a of ancestors) {
    x += a.frame.x;   // ignores a.rotation, a.scale, a.isFlippedHorizontal
    y += a.frame.y;
  }
  return { x, y };
}
// If any ancestor is rotated 90°, this produces nonsense.
```

**Correct (compose 2D transform matrices):**

```ts
type Mat = [number, number, number, number, number, number];   // a, b, c, d, e, f  (CSS matrix())

const identity: Mat = [1, 0, 0, 1, 0, 0];

const multiply = (m1: Mat, m2: Mat): Mat => [
  m1[0]*m2[0] + m1[2]*m2[1],
  m1[1]*m2[0] + m1[3]*m2[1],
  m1[0]*m2[2] + m1[2]*m2[3],
  m1[1]*m2[2] + m1[3]*m2[3],
  m1[0]*m2[4] + m1[2]*m2[5] + m1[4],
  m1[1]*m2[4] + m1[3]*m2[5] + m1[5],
];

function layerMatrix(l: Layer): Mat {
  const { x, y, width, height } = l.frame;
  const cx = x + width / 2, cy = y + height / 2;       // rotation center
  const θ = ((l.rotation ?? 0) * Math.PI) / 180;
  const sx = l.isFlippedHorizontal ? -1 : 1;
  const sy = l.isFlippedVertical   ? -1 : 1;
  const c = Math.cos(θ), s = Math.sin(θ);

  // translate(cx,cy) · rotate · scale · translate(-cx,-cy) · translate(x,y)
  // collapsed into a single 2D affine matrix:
  return [
    c * sx, s * sx, -s * sy, c * sy,
    x + cx - (c * sx * cx - s * sy * cy),
    y + cy - (s * sx * cx + c * sy * cy),
  ];
}

function composedMatrix(layer: Layer, ancestors: Layer[]): Mat {
  return ancestors.reduce((acc, a) => multiply(acc, layerMatrix(a)), identity);
  // (then multiply by layerMatrix(layer) if you want layer-space → page-space)
}

function pageCoords(layer: Layer, ancestors: Layer[]) {
  const M = composedMatrix(layer, ancestors);
  // Apply to (0, 0) in layer's local space:
  return { x: M[4], y: M[5] };
}
```

**Why a single composed matrix:** the resulting `Mat` plugs straight into CSS `transform: matrix(a, b, c, d, e, f)`, so for absolutely-positioned descendants you can emit one transform per leaf instead of nested wrappers. It also makes the inverse (page → layer space) cheap when you need to hit-test against the original Sketch file.

**Sketch quirk — flip semantics:** `isFlippedHorizontal` is applied *before* rotation in Sketch's render pipeline, not after. The composition above respects this; reversing the order produces a mirrored AND rotated result that disagrees with what Sketch shows.

Reference: [W3C CSS Transforms Module Level 1](https://www.w3.org/TR/css-transforms-1/)
