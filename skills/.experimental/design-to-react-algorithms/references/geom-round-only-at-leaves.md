---
title: Carry Floats Through the Pipeline, Round Only at the Leaf
impact: HIGH
impactDescription: prevents 1-5px cumulative drift in 10-level nested trees
tags: geom, rounding, floating-point, cumulative-drift
---

## Carry Floats Through the Pipeline, Round Only at the Leaf

Sketch stores coordinates as floats with up to 15 decimals of subpixel precision. If you round at every pipeline stage — parse, normalize, transform, emit — the rounding errors accumulate: a 10-level nested label drifts 3-5 pixels off-design because each ancestor contributed 0.5px of rounding. Round exactly once, at the emit boundary, after all transforms are composed.

**Incorrect (round at every stage):**

```ts
function parseFrame(f: SketchFrame) {
  return {
    x: Math.round(f.x),       // round 1 — discards 0.3
    y: Math.round(f.y),
    width: Math.round(f.width),
    height: Math.round(f.height),
  };
}

function offsetByParent(child: Frame, parent: Frame) {
  return {
    x: Math.round(child.x + parent.x),   // round 2 — discards another 0.5
    y: Math.round(child.y + parent.y),
    width: child.width,
    height: child.height,
  };
}

// After 10 levels: child has drifted 5px off the design.
```

**Correct (carry floats, round at emit):**

```ts
// Parse keeps full float precision.
function parseFrame(f: SketchFrame): Frame {
  return { x: f.x, y: f.y, width: f.width, height: f.height };
}

// All intermediate transforms operate on floats.
function offsetByParent(child: Frame, parent: Frame): Frame {
  return {
    x: child.x + parent.x,        // 12.3 + 8.7 = 21.0 exactly
    y: child.y + parent.y,
    width: child.width,
    height: child.height,
  };
}

// Round once, at the boundary to CSS, with sensible rules per property.
function emitCss(f: Frame): CssProps {
  return {
    // Positions: round to whole pixel (subpixel positioning blurs text).
    left: `${Math.round(f.x)}px`,
    top:  `${Math.round(f.y)}px`,
    // Sizes: round to whole pixel too, but using floor + ceil for outer hulls
    // would over-include — round-to-nearest matches what the designer saw.
    width:  `${Math.round(f.width)}px`,
    height: `${Math.round(f.height)}px`,
  };
}
```

**Why "round-to-nearest" instead of floor/ceil:** Sketch's canvas rasterizer rounds to nearest pixel at render time. Matching that policy makes your converted React output pixel-identical to Sketch's PNG export, which is what your visual-regression baselines are.

**When to skip rounding entirely:** when emitting transforms (`scale(1.0625)`, `rotate(7.5deg)`) and percentages, leave the float — rounding here changes semantics, not just sub-pixel rendering. Same for `border-radius` of small radii where 1px of rounding is a visible 50% change.

Reference: [IEEE 754 — Floating-Point Arithmetic](https://en.wikipedia.org/wiki/IEEE_754)
