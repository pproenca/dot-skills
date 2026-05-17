---
title: Convert curvePoint Arrays to SVG Cubic Beziers (M then C per segment)
impact: MEDIUM
impactDescription: lossless path conversion; prevents kinked or smoothed-incorrectly curves
tags: path, svg, bezier, curve-point
---

## Convert curvePoint Arrays to SVG Cubic Beziers (M then C per segment)

Sketch stores custom paths as an array of `curvePoint` objects, each carrying three coordinates: `point` (the on-curve anchor), `curveFrom` (the outgoing control handle), and `curveTo` (the incoming control handle). The mapping to SVG path data is mechanical — emit `M` to the first point, then `C curveFrom_i, curveTo_(i+1), point_(i+1)` for each segment. Skipping the control points (`L` to each point) produces straight-line polygons that look right only when every `curveMode` is `straight`.

**Coordinate format note:** `point`, `curveFrom`, `curveTo` are *normalized* in [0, 1] within the parent shape's frame. Multiply by `frame.width`/`frame.height` to get pixel coordinates for the SVG viewBox.

**Incorrect (straight-line approximation, ignores control handles):**

```ts
function pathToSvg(points: CurvePoint[], w: number, h: number): string {
  const [first, ...rest] = points;
  let d = `M ${first.point.x * w} ${first.point.y * h}`;
  for (const p of rest) {
    d += ` L ${p.point.x * w} ${p.point.y * h}`;   // straight line, ignores curves
  }
  return d + ' Z';
  // A rounded heart shape renders as a triangle.
}
```

**Correct (M + per-segment C):**

```ts
type Pt = { x: number; y: number };
// Sketch's raw JSON encodes point fields as strings like "{0.5, 0.3}" — parsePoint
// covers both shapes so the rest of the pipeline can treat them as Pt.
type CurvePoint = {
  point: Pt | string;
  curveFrom: Pt | string;
  curveTo: Pt | string;
  hasCurveFrom: boolean;
  hasCurveTo: boolean;
};

function parsePoint(s: string | Pt): Pt {
  if (typeof s !== 'string') return s;
  const [x, y] = s.replace(/[{} ]/g, '').split(',').map(Number);
  return { x, y };
}

function pathToSvg(points: CurvePoint[], frame: { width: number; height: number }, closed: boolean): string {
  if (points.length === 0) return '';

  const px = (p: Pt) => p.x * frame.width;
  const py = (p: Pt) => p.y * frame.height;
  const at = (p: Pt | string) => parsePoint(p);

  // Move to the first anchor.
  let d = `M ${px(at(points[0].point)).toFixed(3)} ${py(at(points[0].point)).toFixed(3)}`;

  const segCount = closed ? points.length : points.length - 1;
  for (let i = 0; i < segCount; i++) {
    const a = points[i];
    const b = points[(i + 1) % points.length];
    const c1 = at(a.hasCurveFrom ? a.curveFrom : a.point);   // outgoing handle (fall back to anchor)
    const c2 = at(b.hasCurveTo   ? b.curveTo   : b.point);   // incoming handle
    const anchor = at(b.point);
    d += ` C ${px(c1).toFixed(3)} ${py(c1).toFixed(3)},`
       + ` ${px(c2).toFixed(3)} ${py(c2).toFixed(3)},`
       + ` ${px(anchor).toFixed(3)} ${py(anchor).toFixed(3)}`;
  }

  if (closed) d += ' Z';
  return d;
}
```

**Why use C even for straight segments:** when `hasCurveFrom` is false, the control point equals the anchor — the cubic Bezier degenerates to a straight line, and the result is geometrically identical to `L`. Using `C` everywhere keeps the segment count consistent and simplifies path-edit operations (you never have to branch on segment type).

**closed vs open paths:** Sketch's `isClosed` flag on the shape decides whether the last segment connects back to the first. `Z` in SVG closes the *current subpath* — emit it only when `isClosed: true`.

**Performance tip — coordinate precision:** `toFixed(3)` gives sub-pixel accuracy (1/1000 of a pixel is invisible) while keeping the path string compact. SVG paths with 15-digit coordinates inflate file size 5-10x with no visual benefit.

Reference: [SVG 2 — Path Data](https://www.w3.org/TR/SVG2/paths.html#PathData)
