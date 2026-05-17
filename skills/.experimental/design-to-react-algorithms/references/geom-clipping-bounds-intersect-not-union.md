---
title: Intersect Nested Clipping Regions, Don't Union or Replace
impact: HIGH
impactDescription: prevents content escaping nested clips; matches Sketch's clip-stacking semantics
tags: geom, clipping, intersection, nested-clips
---

## Intersect Nested Clipping Regions, Don't Union or Replace

When a clipped subtree contains another clipped subtree, the rendered visible region is the **intersection** of the outer and inner clip shapes. The naïve mistake is to either (1) replace the outer clip with the inner clip (content escapes the outer mask) or (2) union them (content visible outside the outer mask leaks). Compose nested clips by intersection so each level only shrinks the visible region, never expands it.

**Incorrect (inner clip replaces outer):**

```css
.outerClip {
  clip-path: circle(50% at 50% 50%);   /* avatar circle */
}
.outerClip .innerClip {
  /* This is a SECOND clip-path on a child — CSS already intersects clip-paths
     of ancestors and descendants, but ONLY if both use clip-path. Using
     overflow: hidden on the outer and clip-path on the inner does NOT
     intersect — the inner clip silently escapes the outer circle's bounds. */
  clip-path: inset(0 0 0 0 round 8px);
}
```

**Correct (both clips must use the same mechanism — AND share a containing-block chain):**

```css
.outerClip {
  clip-path: circle(50% at 50% 50%);
  /* (do NOT use overflow: hidden here — it does not intersect with descendant clip-path) */
}
.innerClip {
  clip-path: inset(0 0 0 0 round 8px);
  /* Visible region = outerClip ∩ innerClip ONLY when .innerClip's containing
     block IS .outerClip. If .innerClip is position: absolute/fixed and its
     containing block is a different positioned ancestor (skipping .outerClip),
     the outer clip is bypassed entirely. In that case, fall back to the
     explicit intersectRects below and emit a combined clip-path on the inner. */
}
```

**The reliable approach — compute the intersection explicitly and emit it on the inner element:**

This avoids the containing-block gotcha entirely. For rectangular intersections (the common case):

See also [[tree-clipping-mask-is-stacking-context]] for how to set up the stacking context that makes nested clips render correctly under `transform` and `z-index`.

```ts
type Rect = { x: number; y: number; width: number; height: number };

function intersectRects(a: Rect, b: Rect): Rect {
  const x1 = Math.max(a.x, b.x);
  const y1 = Math.max(a.y, b.y);
  const x2 = Math.min(a.x + a.width,  b.x + b.width);
  const y2 = Math.min(a.y + a.height, b.y + b.height);
  return { x: x1, y: y1, width: Math.max(0, x2 - x1), height: Math.max(0, y2 - y1) };
}

function effectiveClipBounds(layer: Layer, ancestors: Layer[]): Rect {
  // Start with the layer's own frame.
  let region: Rect = { ...layer.frame };
  // Intersect with every ancestor that has a clipping mask.
  for (const a of ancestors) {
    if (a.hasClippingMask) {
      region = intersectRects(region, ancestorClipBounds(a));
      if (region.width <= 0 || region.height <= 0) {
        return { x: 0, y: 0, width: 0, height: 0 };  // fully clipped
      }
    }
  }
  return region;
}
```

**Why union is wrong:** a union of clips would expand the visible region, allowing content to render outside the outer clip — exactly the opposite of what clipping means. If you ever feel tempted to union (because something is being clipped that shouldn't be), the bug is upstream: an ancestor that shouldn't be a clip is marked `hasClippingMask: true`.

**Performance note:** for non-rectangular clips, intersection is a path-boolean operation (use paper.js, clipper-lib, or similar). At convert time, prefer letting CSS handle the intersection automatically via nested `clip-path` rather than computing the combined path yourself.

Reference: [W3C CSS Masking Module Level 1 — clip-path](https://www.w3.org/TR/css-masking-1/#the-clip-path)
