---
title: Treat hasClippingMask as a New Stacking Context
impact: CRITICAL
impactDescription: prevents overflow bugs and broken z-index ordering in clipped regions
tags: tree, clipping-mask, stacking-context, overflow
---

## Treat hasClippingMask as a New Stacking Context

See [[geom-clipping-bounds-intersect-not-union]] for the geometric rule that governs how nested clips compose — this rule covers the CSS stacking-context wrapping; that one covers the math of combining multiple clip regions.

A Sketch layer with `hasClippingMask: true` clips all subsequent siblings within its parent group to its own shape. In CSS this requires both a clipping wrapper *and* a new stacking context — otherwise sibling elements with positive z-index escape the mask, transformed children render outside the clip on Safari, and `overflow: hidden` alone fails for non-rectangular shapes. Wrap the mask + its clipped siblings in a single container with `isolation: isolate` and either `overflow: hidden` (rectangular) or `clip-path` (arbitrary shape).

**Incorrect (overflow only, no stacking context):**

```tsx
// Sketch: group containing [rect with hasClippingMask, image, badge with z-index]
return (
  <div className={styles.group}>
    {/* mask shape consumed; emit nothing or emit as background */}
    <img src="avatar.jpg" className={styles.image} />
    <div className={styles.badge}>{/* z-index: 2 to sit above avatar */}NEW</div>
  </div>
);
```

```css
.group { width: 64px; height: 64px; border-radius: 32px; overflow: hidden; }
/* The badge with z-index:2 ESCAPES the clip on Safari + transformed parents.
   The clipping context and the stacking context are not unified. */
```

**Correct (isolated stacking + clip-path for non-rectangular masks):**

```tsx
return (
  <div className={styles.clipWrapper}>
    <img src="avatar.jpg" className={styles.image} />
    <div className={styles.badge}>NEW</div>
  </div>
);
```

```css
.clipWrapper {
  width: 64px;
  height: 64px;
  /* Both clip AND isolate — siblings cannot escape the mask via z-index. */
  clip-path: circle(50% at 50% 50%);   /* non-rect mask */
  isolation: isolate;                  /* new stacking context */
  position: relative;                  /* children's absolute layout anchor */
}

.badge {
  position: absolute;
  top: 0;
  right: 0;
  z-index: 2;     /* stays inside the clip because of isolation */
}
```

**Why `isolation: isolate` and not `z-index: 0`:** `isolation` creates a stacking context without consuming the z-index property, which the badge or other children may still need. Setting `z-index: 0` on the wrapper works but is a footgun — a later edit that removes it silently breaks the clip on Safari.

**For arbitrary masks:** if the mask layer is a custom path (not a rectangle/oval), generate an SVG `<clipPath>` and reference it via `clip-path: url(#mask-id)`. Inline the SVG in the same React tree to avoid cross-document URL issues.

Reference: [MDN — Stacking context](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_positioned_layout/Stacking_context)
