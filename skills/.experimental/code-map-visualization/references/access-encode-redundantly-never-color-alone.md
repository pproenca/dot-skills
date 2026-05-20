---
title: Never Let Color Be the Only Encoding
impact: MEDIUM
impactDescription: prevents state being lost without colour
tags: access, color, redundancy, wcag, perception
---

## Never Let Color Be the Only Encoding

WCAG 1.4.1 requires that colour is never the only way to convey information, because color-vision-deficient users, greyscale displays, and washed-out projectors all drop hue. On a code map this means a status shown only as red/green ([[color-design-for-color-vision-deficiency]]) is invisible to those users; pair it with a shape, icon, pattern, or text label so the meaning survives without colour. This is the rendering-side obligation that the encoding rule ([[encode-redundant-encoding-for-key-signals]]) implements.

**Incorrect (legend distinguishes by colour swatch alone):**

```typescript
const legend = [
  { color: GREEN, label: "passing" },
  { color: RED,   label: "failing" },   // distinguished only by hue
];
```

**Correct (colour plus a shape that survives without colour):**

```typescript
const legend = [
  { color: GREEN, glyph: "circle",   label: "passing" },
  { color: RED,   glyph: "triangle", label: "failing" }, // shape carries it too
];
```

**When NOT to apply:**
- Purely aesthetic, non-informational colour (a brand tint that carries no meaning) has nothing to redundantly encode.

Reference: [WCAG 2.2 — Use of Color (1.4.1)](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html); [Okabe & Ito, Color Universal Design](https://jfly.uni-koeln.de/color/)
