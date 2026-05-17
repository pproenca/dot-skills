---
title: Convert Gradient Vectors to CSS Angles via atan2 with Axis Reframing
impact: MEDIUM-HIGH
impactDescription: prevents 90° rotation errors and mirrored gradients (the #1 design-to-CSS gradient bug)
tags: style, gradient, atan2, angle-conversion
---

## Convert Gradient Vectors to CSS Angles via atan2 with Axis Reframing

Sketch stores a linear gradient as two normalized points `from: {x, y}` and `to: {x, y}` in [0, 1] within the layer's bounding box. CSS `linear-gradient` takes a single angle in *CSS's* angle convention (0deg = bottom-to-top, increasing clockwise). The bug factory is converting `from→to` vector math directly: math convention has 0° = east increasing counter-clockwise, Sketch's Y axis increases downward, and CSS's 0deg is "to top." Reframe explicitly through these three frames.

**Incorrect (raw atan2, no axis reframing):**

```ts
function gradientCss(g: Gradient): string {
  const dx = g.to.x - g.from.x;
  const dy = g.to.y - g.from.y;
  const angleRad = Math.atan2(dy, dx);
  const angleDeg = (angleRad * 180) / Math.PI;
  return `linear-gradient(${angleDeg}deg, ${stops(g)})`;
  // For a vertical top→bottom gradient: from=(0.5, 0), to=(0.5, 1).
  // atan2(1, 0) = 90° → emit linear-gradient(90deg, ...) which is LEFT-TO-RIGHT in CSS.
  // Wrong by 90°.
}
```

**Correct (reframe Sketch coords → CSS angle):**

```ts
// CSS linear-gradient angle convention:
//   0deg   = to top    (gradient goes upward)
//   90deg  = to right
//   180deg = to bottom (the most common)
//   270deg = to left
// Angle measures the direction the gradient FLOWS (start to end).
//
// Sketch (0,0) = top-left, (1,1) = bottom-right. Gradient flows from `from` to `to`.

function gradientCss(g: Gradient): string {
  // Sketch's Y is "down is positive," so a positive dy means the gradient flows downward.
  const dx = g.to.x - g.from.x;
  const dy = g.to.y - g.from.y;

  // Convert "flow direction" vector to CSS angle:
  //   CSS 0° = up → vector (0, -1)
  //   CSS angle θ degrees → vector (sin θ, -cos θ) in screen coords
  // Inverse: θ = atan2(dx, -dy), then convert to degrees and normalize to [0, 360).
  let angleDeg = (Math.atan2(dx, -dy) * 180) / Math.PI;
  angleDeg = ((angleDeg % 360) + 360) % 360;

  return `linear-gradient(${angleDeg.toFixed(2)}deg, ${stops(g)})`;
}

function stops(g: Gradient): string {
  // gradientStops have `position` in [0, 1] along the from→to vector.
  return g.stops
    .sort((a, b) => a.position - b.position)
    .map(s => `${sketchColorToCss(s.color)} ${(s.position * 100).toFixed(2)}%`)
    .join(', ');
}
```

**Verification table — known cases:**

| Sketch from → to | dx, dy | Expected CSS angle |
|---|---|---|
| (0, 0) → (0, 1)   top → bottom | 0, 1 | 180deg ✓ |
| (0, 1) → (0, 0)   bottom → top | 0, -1 | 0deg ✓ |
| (0, 0) → (1, 0)   left → right | 1, 0 | 90deg ✓ |
| (1, 0) → (0, 0)   right → left | -1, 0 | 270deg ✓ |
| (0, 0) → (1, 1)   diagonal | 1, 1 | 135deg ✓ |

If your output doesn't match this table on the basic cases, the reframing is wrong somewhere; do not "tune" the angle by adding 90s.

**Radial gradients:** the same `from`/`to` points define the radius and center for radial — `center = from`, `radius = distance(from, to) * layer.frame.{width, height}`. Emit `radial-gradient(circle Xpx at Cpx Dpx, …)`.

Reference: [W3C CSS Images Module — Linear Gradient Syntax](https://www.w3.org/TR/css-images-3/#linear-gradients)
