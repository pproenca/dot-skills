---
title: Convert Sketch lineHeight (pt) to CSS Unitless via lineHeight / fontSize
impact: MEDIUM
impactDescription: prevents 5-30% line-spacing drift when font-size scales (rem, em, parent-driven)
tags: type, line-height, unitless, conversion
---

## Convert Sketch lineHeight (pt) to CSS Unitless via lineHeight / fontSize

Sketch's `lineHeight` is in absolute points; CSS `line-height` accepts either an absolute length (px/em) or a unitless multiplier. Emitting Sketch's absolute pt as CSS px works at design size but breaks the moment the font scales — a 24px line-height paired with a 14px font (instead of design's 16px) leaves 4px of extra leading, visually doubling the gap below ascenders. Use unitless `lineHeight / fontSize`, which scales with the font automatically and is the universally-recommended CSS practice.

**Incorrect (absolute px line-height):**

```ts
function textCss(t: SketchTextStyle): CssProps {
  return {
    fontSize: `${t.fontSize}px`,
    lineHeight: `${t.lineHeight}px`,
    // Sketch: fontSize 16, lineHeight 24. Emit: lineHeight 24px.
    // User sets html { font-size: 87.5% } for a smaller base — fontSize becomes 14px,
    // but lineHeight stays at 24px, giving 1.71 ratio instead of designed 1.5.
  };
}
```

**Correct (unitless multiplier):**

```ts
function textCss(t: SketchTextStyle): CssProps {
  const ratio = t.lineHeight / t.fontSize;     // 24 / 16 = 1.5
  return {
    fontSize:   `${t.fontSize}px`,
    lineHeight: ratio.toFixed(3).replace(/\.?0+$/, ''),  // "1.5"
    // Scales with font: at 14px font, line-height becomes 21px (still 1.5 ratio).
  };
}

// Sketch fallback case: lineHeight 0 means "use font's natural metrics."
function lineHeightCss(t: SketchTextStyle): string {
  if (!t.lineHeight || t.lineHeight === 0) return 'normal';   // CSS default
  return (t.lineHeight / t.fontSize).toFixed(3).replace(/\.?0+$/, '');
}
```

**Why unitless is universally recommended:** the CSS spec explicitly notes that unitless `line-height` is preferred because it inherits as a *factor*, not a computed pixel value — so a child element with a different font-size still gets correctly-proportional leading. Using px or em causes the parent's *computed* line-height (in px) to inherit, breaking proportionality at every font-size change down the tree.

**The 14-15 character ratio range:** typographic line-height ratios fall in [1.2, 1.6] for body text, [1.05, 1.2] for display text, [1.4, 1.8] for long-form. If your computed ratio falls outside [1.0, 2.0], either the Sketch data is wrong (lineHeight in px instead of pt, common bug) or it's a single-line label where the ratio is irrelevant — sniff for `attributedString.string` containing a `\n` to distinguish.

Reference: [MDN — line-height — Prefer unitless values](https://developer.mozilla.org/en-US/docs/Web/CSS/line-height#prefer_unitless_numbers_for_line-height_values)
