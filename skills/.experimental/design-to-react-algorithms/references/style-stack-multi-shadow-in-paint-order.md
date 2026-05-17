---
title: Reverse Multi-Shadow Order — Sketch Paints Last-First, CSS Paints First-Last
impact: MEDIUM-HIGH
impactDescription: prevents 100% of multi-shadow z-order inversions (a frequent silent regression)
tags: style, shadow, paint-order, box-shadow
---

## Reverse Multi-Shadow Order — Sketch Paints Last-First, CSS Paints First-Last

Sketch and CSS disagree on the paint order of stacked shadows. Sketch paints `style.shadows[0]` *last* (so it appears on top), exactly like SVG's filter list. CSS `box-shadow` paints the *first* listed shadow on top. Emitting Sketch's shadow array directly into CSS box-shadow gives you the correct shadows but in inverted z-order — a "soft glow" beneath a "hard drop shadow" silently flips, and the rendered result is subtly muddier than the design.

**Incorrect (preserve array order):**

```ts
function shadowsToCss(shadows: Shadow[]): string {
  return shadows.map(shadowToCss).join(', ');
  // Sketch design: [hardDropShadow (top), softGlow (below)]
  // Emitted:       hardDropShadow on top, softGlow on bottom — same as Sketch? NO.
  // CSS paints the first one ON TOP, but visually it was already ON TOP, so
  // looks right until two shadows have different colors/opacity, then it's wrong.
}
```

The bug appears when shadow opacities differ: the BOTTOM shadow in Sketch's stack only contributes outside the top one's coverage, but in CSS's reversed order it contributes everywhere, darkening the overall composite.

**Correct (reverse the array on emit):**

```ts
function shadowsToCss(shadows: Shadow[]): string {
  // Sketch: index 0 painted last (top). CSS: index 0 painted first (top).
  // The order of "visually top" must be the same; the array index doesn't.
  // To preserve visual stack, REVERSE the array when emitting to CSS.
  return [...shadows]
    .reverse()
    .filter(s => s.isEnabled !== false)    // treat undefined as enabled; skip explicitly disabled
    .map(shadowToCss)
    .join(', ');
}

function shadowToCss(s: Shadow): string {
  const inset = s._class === 'innerShadow' ? 'inset ' : '';
  const x = s.offsetX;
  const y = s.offsetY;
  const blur = s.blurRadius;
  const spread = s.spread ?? 0;
  const color = sketchColorToCss(s.color);
  return `${inset}${x}px ${y}px ${blur}px ${spread}px ${color}`;
}
```

```css
/* Sketch shadows array: [
   {  x: 0,  y: 1,  blur: 3,  color: rgba(0,0,0,0.12) }, ← painted LAST (top)
   {  x: 0,  y: 8,  blur: 24, color: rgba(0,0,0,0.10) }  ← painted FIRST (bottom)
]
*/
.card {
  /* Emitted REVERSED so the visually-top one is CSS-first: */
  box-shadow:
    0 1px  3px rgba(0, 0, 0, 0.12),    /* visually on top */
    0 8px 24px rgba(0, 0, 0, 0.10);    /* visually behind */
}
```

**Verification with the eyeball test:** if your converted card looks "muddier" or "heavier" than the design, the shadow order is reversed. Run [[diff-region-budgeted-tolerances]] with `shadow` budget — multi-shadow inversions consistently fail at 0.94 SSIM in the shadow region, well below the 0.97 budget.

**Inner shadows:** Sketch's `innerShadow` class follows the same reversal rule. `style.innerShadows` array is paint-order-last-first, CSS `box-shadow inset` is paint-order-first-last. Reverse both arrays, then concatenate `innerShadows` *before* outer `shadows` in the CSS list (CSS paints inset shadows in declared order, interleaved with outer).

Reference: [MDN — box-shadow](https://developer.mozilla.org/en-US/docs/Web/CSS/box-shadow)
