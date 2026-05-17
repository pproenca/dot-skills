---
title: Preserve `wrappingEnabled` as `flex-wrap`, Not a Width Hack
impact: HIGH
impactDescription: preserves responsive intent at non-design widths; eliminates fixed-width breakpoints on row containers
tags: layout, flex-wrap, responsive, sketch-autolayout
---

## Preserve `wrappingEnabled` as `flex-wrap`, Not a Width Hack

`MSImmutableFlexGroupLayout.wrappingEnabled` is the designer's explicit statement of how the layout behaves on different widths. Mapping `false → flex-wrap: nowrap` and `true → flex-wrap: wrap` is the only correct translation; substituting a fixed parent width (because "it looks right at design width") destroys the responsive contract. Wrapping behavior is also where `crossAxisGutterGap` becomes meaningful — it's the row-gap that opens up when items wrap to a new line.

**Incorrect (hard-coded width substituting for wrap):**

```css
/* From a wrappingEnabled: true tag-list group at design width 320px. */
.tagList {
  display: flex;
  flex-direction: row;
  gap: 8px;
  width: 320px;    /* "looks right at design size" */
  overflow: hidden;  /* hide tags that don't fit */
}
/* Result: at 600px the layout is fine but doesn't expand;
   at 200px tags are clipped instead of wrapping to a second row. */
```

**Correct (preserve wrap + crossAxisGutterGap):**

```ts
function emitWrappingFlex(L: MSImmutableFlexGroupLayout, axis: 'row' | 'column'): CssProps {
  if (!L.wrappingEnabled) {
    return { flexWrap: 'nowrap' };   // (gap on main axis, no row-gap needed)
  }
  return {
    flexWrap: 'wrap',
    // crossAxisGutterGap is the gap BETWEEN wrapped lines.
    [axis === 'row' ? 'rowGap' : 'columnGap']: `${L.crossAxisGutterGap}px`,
  };
}
```

```css
.tagList {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  column-gap: 8px;     /* main-axis = allGuttersGap */
  row-gap: 6px;        /* cross-axis = crossAxisGutterGap, opens up when wrapped */
  /* no fixed width — container is responsive */
}
```

**Why this is non-negotiable:** wrapping is one of the few design behaviors that the Sketch file *cannot* otherwise communicate. Coordinates capture position at one width; only `wrappingEnabled` captures behavior across widths. Discarding it forces the React consumer to re-author responsive logic that the designer already specified.

**Gotcha — Sketch alignContent vs CSS align-content:** for multi-line wrap, `alignContent` controls how wrapped lines are distributed in the cross direction. Sketch's `alignContent: 0` is `stretch`; verify other enum values against your test file before mapping.

Reference: [MDN — flex-wrap](https://developer.mozilla.org/en-US/docs/Web/CSS/flex-wrap)
