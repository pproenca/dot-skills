---
title: Use accent-* Classes for Color Prop Extraction
impact: HIGH
impactDescription: correctly extracts color values for non-style props
tags: comp, accent, color, extraction
---

## Use accent-* Classes for Color Prop Extraction

When extracting color values for props (not styles), use `accent-*` prefixed classes. Standard `text-*` or `bg-*` classes won't work for value extraction.

**Incorrect (using text-* for color extraction):**

```tsx
const StyledIcon = withUniwind(Icon, {
  color: {
    fromClassName: 'colorClassName',
    styleProperty: 'color',
  },
})

// text-primary doesn't work for color prop extraction
<StyledIcon name="heart" colorClassName="text-primary" />
```

**Correct (using accent-* for extraction):**

```tsx
const StyledIcon = withUniwind(Icon, {
  color: {
    fromClassName: 'colorClassName',
    styleProperty: 'accentColor',  // Note: accentColor, not color
  },
})

// accent-* classes work for value extraction
<StyledIcon name="heart" colorClassName="accent-primary" />
```

**Pattern for SVG components:**

```tsx
export const SvgIcon = withUniwind(BaseSvgIcon, {
  stroke: {
    fromClassName: 'strokeClassName',
    styleProperty: 'accentColor',
  },
  fill: {
    fromClassName: 'fillClassName',
    styleProperty: 'accentColor',
  },
})
```

```tsx
<SvgIcon
  strokeClassName="accent-foreground"
  fillClassName="accent-primary"
/>
```

Reference: [Uniwind withUniwind API](https://docs.uniwind.dev/api/with-uniwind)
