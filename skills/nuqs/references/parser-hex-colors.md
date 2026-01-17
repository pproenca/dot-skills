---
title: Use parseAsHex for Color Values
impact: MEDIUM
impactDescription: 50% shorter URLs for color parameters
tags: parser, parseAsHex, colors, hexadecimal
---

## Use parseAsHex for Color Values

When storing color values in URLs, `parseAsHex` provides cleaner hexadecimal representation instead of decimal numbers.

**Incorrect (decimal in URL):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function ColorPicker() {
  const [color, setColor] = useQueryState(
    'color',
    parseAsInteger.withDefault(0xff0000)
  )
  // URL: ?color=16711680 (not human-readable)

  const hexString = color.toString(16).padStart(6, '0')

  return (
    <input
      type="color"
      value={`#${hexString}`}
      onChange={e => setColor(parseInt(e.target.value.slice(1), 16))}
    />
  )
}
```

**Correct (hex in URL):**

```tsx
'use client'
import { useQueryState, parseAsHex } from 'nuqs'

export default function ColorPicker() {
  const [color, setColor] = useQueryState(
    'color',
    parseAsHex.withDefault(0xff0000)
  )
  // URL: ?color=ff0000 (human-readable)
  // State: 16711680 (number for calculations)

  const hexString = color.toString(16).padStart(6, '0')

  return (
    <input
      type="color"
      value={`#${hexString}`}
      onChange={e => setColor(parseInt(e.target.value.slice(1), 16))}
    />
  )
}
```

**Benefits:**
- URLs are readable: `?color=ff0000` vs `?color=16711680`
- State is numeric for calculations
- Standard hex color format in URL

Reference: [nuqs parseAsHex](https://nuqs.dev/docs/parsers)
