---
title: Emit Rotation as CSS transform, Not a Pre-Rotated Bounding Box
impact: HIGH
impactDescription: prevents 5-30% width/height inflation on rotated layers; keeps text legible
tags: geom, rotation, transform, bounding-box
---

## Emit Rotation as CSS transform, Not a Pre-Rotated Bounding Box

A Sketch layer's `frame` is its *unrotated* axis-aligned bounding box, and `rotation` is the angle applied at render time around the frame's center. The common mistake is to compute the rotated bounding box (the larger AABB after rotation) and emit *that* as the element's width/height — which inflates the element, breaks text wrapping inside it, and prevents CSS from animating the rotation. Always emit the frame's original size + `transform: rotate(Ndeg)`.

**Incorrect (pre-rotate to AABB):**

```ts
function emitRotated(layer: Layer): CssProps {
  const θ = (layer.rotation * Math.PI) / 180;
  const { width: w, height: h } = layer.frame;
  // Larger AABB after rotating w×h by θ:
  const rotatedW = Math.abs(w * Math.cos(θ)) + Math.abs(h * Math.sin(θ));
  const rotatedH = Math.abs(w * Math.sin(θ)) + Math.abs(h * Math.cos(θ));
  return {
    width:  `${rotatedW}px`,    // INFLATED — text inside re-wraps
    height: `${rotatedH}px`,
    background: '...',          // background canvas is now wrong shape
  };
}
```

**Correct (original size + CSS rotation):**

```ts
function emitRotated(layer: Layer): CssProps {
  return {
    width:  `${layer.frame.width}px`,
    height: `${layer.frame.height}px`,
    // CSS rotates around `transform-origin: 50% 50%` by default, which matches
    // Sketch's rotation center (frame midpoint). Don't override unless the
    // layer has a custom rotation origin (rare).
    ...(layer.rotation && {
      // Invert sign: Sketch is counter-clockwise from east, CSS is clockwise from north.
      transform: `rotate(${-layer.rotation}deg)`,
    }),
  };
}
```

```css
/* Sketch frame: 200×40, rotation: -15° */
.banner {
  width: 200px;
  height: 40px;
  transform: rotate(-15deg);
  /* Text inside wraps at 200px — matches design.
     Element still occupies its visual rotated box for hit-testing,
     but CSS layout reserves the unrotated rectangle (which is what we want). */
}
```

**Warning — Sketch rotation sign:** CSS `rotate(Ndeg)` is **clockwise from the top (12 o'clock)**; Sketch's `rotation` is **counter-clockwise from the right (3 o'clock)**. Invert the sign when emitting: `transform: rotate(${-layer.rotation}deg)`. Verify against your test file; if your output is mirrored, flip the sign back.

**For layout: rotation does NOT affect the element's reserved space in flow.** A rotated child still reserves its unrotated bounding box in the flex/grid container. This matches Sketch's auto-layout behavior, so it's the correct mapping.

Reference: [CSS Transforms — transform-origin](https://www.w3.org/TR/css-transforms-1/#transform-origin-property)
