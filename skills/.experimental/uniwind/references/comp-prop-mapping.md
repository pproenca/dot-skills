---
title: Use Custom Prop Mappings for Non-Style Props
impact: HIGH
impactDescription: enables Tailwind classes for color, width, and other non-style props
tags: comp, with-uniwind, prop-mapping, custom-props
---

## Use Custom Prop Mappings for Non-Style Props

Some components accept props like `color` or `size` as values, not styles. Use custom mappings to extract specific values from Tailwind classes.

**Incorrect (trying to use className for color prop):**

```tsx
import { Icon } from 'some-icon-library'

// Icon expects color="#3b82f6", not a style object
<Icon name="star" className="text-primary" />
```

**Correct (custom prop mapping):**

```tsx
// styled.ts
import { withUniwind } from 'uniwind'
import { Icon as BaseIcon } from 'some-icon-library'

export const Icon = withUniwind(BaseIcon, {
  color: {
    fromClassName: 'colorClassName',
    styleProperty: 'color',  // Extract color value
  },
  size: {
    fromClassName: 'sizeClassName',
    styleProperty: 'width',  // Extract width value as size
  },
})
```

```tsx
// Now use accent-* classes for color extraction
<Icon
  name="star"
  colorClassName="accent-primary"
  sizeClassName="w-6"
/>
```

**Common mappings:**
- `color` → `colorClassName` with `accent-*` classes
- `strokeColor` / `fillColor` for SVGs
- `size` from width classes

Reference: [Uniwind withUniwind API](https://docs.uniwind.dev/api/with-uniwind)
