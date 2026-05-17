---
title: Map MSImmutableFlexGroupLayout Enums Directly to CSS Flexbox
impact: CRITICAL
impactDescription: prevents 100% of layout-intent loss for auto-layout groups; eliminates re-inference work
tags: layout, flexbox, sketch-autolayout, enum-mapping
---

## Map MSImmutableFlexGroupLayout Enums Directly to CSS Flexbox

When a Sketch group has a `layout` of `MSImmutableFlexGroupLayout`, the designer explicitly modeled the layout as flexbox — Sketch's auto-layout is a near-1:1 mirror of CSS Flexbox. Do not re-infer; map the enums directly. Re-inferring from child positions throws away the designer's stated intent and produces inconsistent results when the layout is rendered at a different size.

The enum mapping (per Sketch's `MSImmutableFlexGroupLayout` definition):

| Sketch property | Sketch value | CSS property | CSS value |
|---|---|---|---|
| `flexDirection` | 0, 1, 2, 3 | `flex-direction` | `row`, `column`, `row-reverse`, `column-reverse` |
| `justifyContent` | 0, 1, 2, 3, 4 | `justify-content` | `flex-start`, `center`, `flex-end`, `space-between`, `space-around` |
| `alignItems` | 0, 1, 2, 3 | `align-items` | `flex-start`, `center`, `flex-end`, `stretch` |
| `wrappingEnabled` | false / true | `flex-wrap` | `nowrap` / `wrap` |
| `allGuttersGap` | N (px) | `gap` (main axis) | `Npx` |
| `crossAxisGutterGap` | N (px) | `row-gap` / `column-gap` | `Npx` |

**Incorrect (re-inferring from child positions, ignoring the explicit layout):**

```ts
function emitGroupLayout(group: Group): string {
  // Heuristic: look at child positions and guess.
  if (childrenStackedHorizontally(group)) return 'display: flex; flex-direction: row;';
  if (childrenStackedVertically(group))   return 'display: flex; flex-direction: column;';
  return 'position: relative;';   // fallback to absolute children
}
// Loses justifyContent, alignItems, gap, wrapping — all the parts that make
// the layout responsive at non-design widths.
```

**Correct (direct enum mapping, no inference):**

```ts
const FLEX_DIRECTION = ['row', 'column', 'row-reverse', 'column-reverse'] as const;
const JUSTIFY        = ['flex-start', 'center', 'flex-end', 'space-between', 'space-around'] as const;
const ALIGN_ITEMS    = ['flex-start', 'center', 'flex-end', 'stretch'] as const;

function emitGroupLayout(group: Group): CssProps {
  if (group.layout?._class !== 'MSImmutableFlexGroupLayout') {
    return inferFreeformLayout(group);    // see layout-infer-flex-from-axis-projection-overlap
  }
  const L = group.layout;
  const isRow = L.flexDirection === 0 || L.flexDirection === 2;
  return {
    display: 'flex',
    flexDirection: FLEX_DIRECTION[L.flexDirection],
    justifyContent: JUSTIFY[L.justifyContent],
    alignItems: ALIGN_ITEMS[L.alignItems],
    flexWrap: L.wrappingEnabled ? 'wrap' : 'nowrap',
    // allGuttersGap is the main-axis gap; cross-axis only applies when wrapping.
    [isRow ? 'columnGap' : 'rowGap']: `${L.allGuttersGap}px`,
    ...(L.wrappingEnabled && {
      [isRow ? 'rowGap' : 'columnGap']: `${L.crossAxisGutterGap}px`,
    }),
  };
}
```

**Warning (verify the enum order against your Sketch version):** the enum integers are not formally specified in Sketch's public docs; verify them against `MSImmutableFlexGroupLayout` instances in a known-good file before shipping. The mapping above matches Sketch 2025.x; older files may use a different `alignContent` index.

Reference: [W3C CSS Flexible Box Layout Module Level 1](https://www.w3.org/TR/css-flexbox-1/)
