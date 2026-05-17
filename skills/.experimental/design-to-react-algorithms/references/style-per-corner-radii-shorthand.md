---
title: Map MSImmutableStyleCorners to border-radius 4-Value Shorthand
impact: MEDIUM-HIGH
impactDescription: emits 1 declaration instead of 4 separate corner properties; preserves designer per-corner intent
tags: style, border-radius, corners, shorthand
---

## Map MSImmutableStyleCorners to border-radius 4-Value Shorthand

A Sketch rectangle's corner radii live in two places — `fixedRadius` (uniform) and `MSImmutableStyleCorners` (per-corner). For per-corner cases, the CSS `border-radius` shorthand accepts up to 4 values in the order `top-left top-right bottom-right bottom-left` (clockwise from top-left). Emit the shorthand instead of 4 separate `border-top-left-radius: ...` declarations: it's a single line, survives copy-paste, and makes "all four corners are equal" visually obvious.

**Sketch's per-corner order vs CSS:**

```text
Sketch: cornerStyle = { topLeft, topRight, bottomLeft, bottomRight }
CSS:    border-radius: TL TR BR BL    (clockwise from top-left)
```

Note the order difference — Sketch is `TL, TR, BL, BR` (rows), CSS is `TL, TR, BR, BL` (clockwise). Map them, don't just pass through.

**Incorrect (passthrough preserves Sketch order, swaps BR/BL):**

```ts
function cornersCss(c: Corners): CssProps {
  return {
    borderRadius: `${c.topLeft}px ${c.topRight}px ${c.bottomLeft}px ${c.bottomRight}px`,
    // Wrong! CSS reads this as TL TR BR BL — bottomLeft is in the BR slot.
    // A "rounded top, square bottom-left only" rectangle ends up rounded
    // on bottom-right instead. Diff fails on the corner.
  };
}
```

**Correct (clockwise order, with collapsing):**

```ts
type Corners = { topLeft: number; topRight: number; bottomLeft: number; bottomRight: number };

function cornersCss(c: Corners | number): CssProps {
  // Uniform case — Sketch fixedRadius — use the 1-value shorthand.
  if (typeof c === 'number') {
    return c > 0 ? { borderRadius: `${c}px` } : {};
  }
  const { topLeft: tl, topRight: tr, bottomRight: br, bottomLeft: bl } = c;
  // Collapse: if all four are equal, emit 1 value.
  if (tl === tr && tr === br && br === bl) {
    return tl > 0 ? { borderRadius: `${tl}px` } : {};
  }
  // CSS clockwise order: TL TR BR BL.
  return { borderRadius: `${tl}px ${tr}px ${br}px ${bl}px` };
}

// Caller — reconcile fixedRadius vs MSImmutableStyleCorners:
function rectCorners(rect: Rectangle): Corners | number {
  if (rect.styleCorners) {
    return {
      topLeft:     rect.styleCorners.topLeft,
      topRight:    rect.styleCorners.topRight,
      bottomRight: rect.styleCorners.bottomRight,
      bottomLeft:  rect.styleCorners.bottomLeft,
    };
  }
  return rect.fixedRadius ?? 0;
}
```

**Smooth corners — different rule applies:** Sketch's "Smooth Corners" toggle paints a superellipse rather than a circular arc. CSS `border-radius` is always a circular (or elliptical) arc. For smooth corners, the per-corner shorthand is *not* a faithful representation — see [[path-apple-smooth-corners-via-superellipse]] for the SVG-based fallback.

**Elliptical radii (rare):** if Sketch ever produces non-square per-axis radii (`borderRadius: '8px / 12px'` syntax in CSS), the shorthand extends to two groups of 4 separated by `/`. Sketch as of 2025.x doesn't expose this in the UI but the file format supports it via separate `radiusX`/`radiusY` on `curvePoint` — emit only if both axes differ.

Reference: [W3C CSS Backgrounds and Borders Module — border-radius](https://www.w3.org/TR/css-backgrounds-3/#border-radius)
