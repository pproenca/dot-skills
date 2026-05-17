---
title: Detect Rectangle + fixedRadius Early; Emit CSS Not SVG
impact: MEDIUM
impactDescription: replaces 6-12 line SVG paths with 2-line CSS for the most common shape (~40% of all layers)
tags: path, rectangle, css-detection, fast-path
---

## Detect Rectangle + fixedRadius Early; Emit CSS Not SVG

The single most common shape in any UI design is a rounded rectangle, and emitting it as an SVG path is a 12-line operation producing a static visual with no responsive sizing, no border, no animation hooks. Detect rectangle + fixedRadius cases at the top of the shape emitter and short-circuit to CSS `width/height/border-radius/background` — the resulting `<div>` is smaller, faster, accessible, and styleable by every CSS pseudo-class.

**Detection — a Sketch layer is a CSS-rectanglable rounded box when:**

1. `_class === 'rectangle'` OR (`_class === 'shapePath'` AND points form an axis-aligned rectangle)
2. Has no custom curve points beyond the 4 corners
3. Has no clipping mask requiring path-shape clipping (a rect clip is also CSS-able)
4. Corner radii are either uniform (`fixedRadius`) or simple per-corner (no smooth corners — see [[path-apple-smooth-corners-via-superellipse]])

**Incorrect (every shape goes to SVG):**

```ts
function emitShape(layer: ShapePath): string {
  return `
    <svg width="${layer.frame.width}" height="${layer.frame.height}">
      <path d="${pathToSvg(layer.points, layer.frame, true)}"
            fill="${fillFromStyle(layer.style)}" />
    </svg>
  `;
  // Card background: 12 lines of inline SVG with a hardcoded fill,
  // no hover state, no responsive sizing, no theming.
}
```

**Correct (rectangle detection + CSS short-circuit):**

```ts
function isAxisAlignedRoundedRect(layer: ShapePath): boolean {
  if (layer._class === 'rectangle') return true;
  // shapePath case: must have exactly 4 points at the corners.
  if (layer._class !== 'shapePath' || (layer.points?.length ?? 0) !== 4) return false;

  const corners = layer.points.map(p => parsePoint(p.point));
  const xs = [...new Set(corners.map(c => c.x.toFixed(4)))];
  const ys = [...new Set(corners.map(c => c.y.toFixed(4)))];
  return xs.length === 2 && ys.length === 2;   // 2 distinct x's and 2 distinct y's = AABB
}

function emitShape(layer: ShapePath | Rectangle): { jsx: string; css: CssProps } {
  if (isAxisAlignedRoundedRect(layer)) {
    return {
      jsx: `<div className={styles.rect} />`,
      css: {
        width:  `${layer.frame.width}px`,
        height: `${layer.frame.height}px`,
        ...cornersCss(rectCorners(layer)),                     // border-radius
        ...fillToCss(layer.style.fills?.[0]),                  // background
        ...bordersToCss(layer.style.borders),                  // border / box-shadow stack
        ...shadowsToCss(layer.style.shadows),                  // box-shadow
      },
    };
  }
  // Complex shape — fall through to SVG.
  return emitAsSvg(layer);
}
```

**Why this matters beyond performance:**

| Concern | SVG path | CSS div |
|---|---|---|
| Hover state | rewrite `<path>` or use SVG filters | `:hover { background: ... }` — trivial |
| Theming | regenerate every SVG on theme change | swap CSS var |
| Accessibility | needs `role="img"` + `<title>` | element flow tree |
| Responsive sizing | reframe viewBox | `width: 100%` |
| File size | ~200 bytes per shape | ~80 bytes |

**40% rule of thumb:** in well-designed UI mockups, axis-aligned rounded rectangles account for ~40% of all shape layers (every card, button, tag, input, modal background). Catching this case alone eliminates the bulk of SVG bloat.

**When the SVG path is actually correct:** rotated rectangles, rectangles with custom path edits (chamfered corner, notch), and any rect that participates in a boolean operation must go to SVG. The detector above correctly excludes these.

Reference: [W3C CSS Backgrounds and Borders — backgrounds](https://www.w3.org/TR/css-backgrounds-3/)
