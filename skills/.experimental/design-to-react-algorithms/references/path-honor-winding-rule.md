---
title: Honor windingRule When Mapping to SVG fill-rule
impact: MEDIUM
impactDescription: prevents 100% mis-fill on shapes with holes (rings, hollow text, donut charts)
tags: path, winding-rule, fill-rule, svg
---

## Honor windingRule When Mapping to SVG fill-rule

Sketch's `windingRule` controls how nested or self-intersecting subpaths are filled: `0` = non-zero (default), `1` = even-odd. They disagree on shapes with holes. A donut shape (outer circle with inner circle hole) under non-zero fills the entire outer disk (because both subpaths have the same winding direction); under even-odd it correctly leaves the hole transparent. Map Sketch's value through to SVG's `fill-rule` attribute — never assume a default.

**The geometric rule, briefly:**

- **non-zero**: count signed crossings of a ray from the point to infinity. Inside if non-zero. Filling depends on subpath direction (CW vs CCW).
- **even-odd**: count crossings, ignoring direction. Inside if odd. Independent of subpath direction — the standard for "shape with hole" patterns.

**Incorrect (omit fill-rule, accept SVG default of nonzero):**

```ts
function emitFilledPath(d: string, fill: string): string {
  return `<path d="${d}" fill="${fill}" />`;
  // For a Sketch donut (outer + inner subpath in the same winding direction):
  // SVG defaults to nonzero → fills the hole. Donut looks like a solid disk.
}
```

**Correct (map windingRule explicitly):**

```ts
function emitFilledPath(d: string, fill: string, windingRule: 0 | 1): string {
  const rule = windingRule === 1 ? 'evenodd' : 'nonzero';
  return `<path d="${d}" fill="${fill}" fill-rule="${rule}" />`;
}

// At the shape emitter:
function shapeToSvg(layer: ShapePath): string {
  const d = pathToSvg(layer.points, layer.frame, layer.isClosed);
  const fill = fillFromStyle(layer.style);
  return emitFilledPath(d, fill, layer.style?.windingRule ?? 0);
}
```

**Test case — a donut:**

```svg
<!-- Outer ring + inner hole subpath, both clockwise. -->
<path d="M 50 10 A 40 40 0 1 0 50 90 A 40 40 0 1 0 50 10 Z
         M 50 30 A 20 20 0 1 0 50 70 A 20 20 0 1 0 50 30 Z"
      fill="black"
      fill-rule="evenodd" />
<!-- With nonzero (default): solid disk. With evenodd: donut with visible hole. -->
```

**When to deliberately use nonzero with reversed winding:** if a path library generates the inner subpath counter-clockwise to the outer (the "correct" non-zero way), `fill-rule: nonzero` *will* leave the hole. Sketch's path exporter doesn't reverse winding for holes, so you almost always want even-odd; but `pathToSvg` upstream may normalize winding, in which case nonzero works. Check your converter's output on a known donut before locking in the default.

**Hollow text and font glyphs:** glyphs like O, A, P, 0, 8 all rely on even-odd fill for their counter (the enclosed white space). Fortunately SVG `<text>` handles this internally — the rule only matters when you emit text *as paths* (e.g., for icon fonts converted at build time).

**Common Sketch source — compound shapes:** any `shapeGroup` with a `subtract` boolean operation flattened via [[path-flatten-boolean-ops-at-parse-time]] produces a result whose winding is now system-dependent. Always set `fill-rule="evenodd"` on flattened subtract results — it's the safe choice for any hole-containing path.

Reference: [SVG 2 — fill-rule](https://www.w3.org/TR/SVG2/painting.html#FillRuleProperty)
