---
title: Reconcile Border Position (Center/Inside/Outside) into Width Offsets
impact: MEDIUM-HIGH
impactDescription: prevents 1-2px sibling overlap or gap from misinterpreted border position
tags: style, border, position, frame-offsets
---

## Reconcile Border Position (Center/Inside/Outside) into Width Offsets

Sketch's `borderOptions.position` (0 = center, 1 = inside, 2 = outside) decides where the stroke is painted relative to the shape's path. CSS `border` is *always* inside the box. If Sketch says "outside 2px," the visual element is 4px larger than the frame; if you emit it as a CSS `border: 2px` on the original frame, sibling layout shifts by 2px in every direction. Reconcile by adjusting the box's width/height and offset, OR by using `outline` for the outside case.

**The geometry:**

| Sketch position | Visual width | CSS strategy |
|---|---|---|
| Inside (1) | frame stays as-is | `border: Npx ...` — CSS native, no adjustment |
| Center (0) | frame + N/2 outward on each side | Expand box by N, offset by -N/2 |
| Outside (2) | frame + N outward on each side | Expand box by 2N, offset by -N — OR use `outline` |

**Incorrect (emit Sketch border directly as CSS border):**

```ts
function borderToCss(b: Border, frame: Frame): CssProps {
  return {
    border: `${b.thickness}px solid ${sketchColorToCss(b.color)}`,
    // For position: 2 (outside), the visual is 2*thickness wider than the frame.
    // But this CSS emits an INSET border, shrinking the content box.
    // Siblings that were 8px away in the design are now 6px away — wrong.
  };
}
```

**Correct (reconcile per position):**

```ts
function borderToCss(b: Border, frame: Frame): { css: CssProps; frameAdjust: Frame } {
  const t = b.thickness;
  const color = sketchColorToCss(b.color);

  switch (b.position) {
    case 1: /* inside */
      return {
        css: { border: `${t}px solid ${color}` },
        frameAdjust: frame,  // unchanged
      };

    case 0: /* center */
      return {
        css: {
          border: `${t}px solid ${color}`,
          // Expand box by t (half outward each side), offset by -t/2.
          width:  `${frame.width  + t}px`,
          height: `${frame.height + t}px`,
        },
        frameAdjust: {
          ...frame,
          x: frame.x - t / 2,
          y: frame.y - t / 2,
          width:  frame.width  + t,
          height: frame.height + t,
        },
      };

    case 2: /* outside */
      // Two options. (A) box expansion (keeps element in flow):
      return {
        css: {
          border: `${t}px solid ${color}`,
          width:  `${frame.width  + 2 * t}px`,
          height: `${frame.height + 2 * t}px`,
        },
        frameAdjust: {
          ...frame,
          x: frame.x - t,
          y: frame.y - t,
          width:  frame.width  + 2 * t,
          height: frame.height + 2 * t,
        },
      };
    // (B) outline — does NOT occupy layout space; ideal for focus rings:
    //     return { css: { outline: `${t}px solid ${color}` }, frameAdjust: frame };
  }
}
```

**When to choose outline over expansion:** if the border represents a *focus ring* or *selection highlight* that should never push siblings around, use `outline`. Outline paints outside the box without taking layout space — exactly the "outside but ignored by flex/grid" semantics. The Sketch frame in this case has been drawn at the inner edge specifically because the designer also wanted it not to affect layout.

**Multiple borders (Sketch allows N stacked borders):** CSS supports only one `border` shorthand. Stack additional borders via `box-shadow` with `spread` (inset for inside-aligned, outset for outside-aligned). Emit the outermost border via CSS border and inner ones via inset shadows.

Reference: [MDN — outline vs border](https://developer.mozilla.org/en-US/docs/Web/CSS/outline)
