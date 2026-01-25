---
title: Use Border Radius Variable for Consistent Corners
impact: MEDIUM
impactDescription: single point of control for border radius across all components
tags: style, border-radius, css-variables, consistency
---

## Use Border Radius Variable for Consistent Corners

Use the `--radius` CSS variable instead of hardcoded Tailwind classes. This enables design system-wide border radius changes from a single location.

**Incorrect (hardcoded radius values):**

```tsx
function Card() {
  return <div className="rounded-lg p-4">...</div>
}

function Button() {
  return <button className="rounded-md px-4">...</button>
}

function Input() {
  return <input className="rounded px-3" />
}
// Inconsistent: lg vs md vs default
// Changing design system requires editing every component
```

**Correct (CSS variable for radius):**

```css
/* globals.css */
:root {
  --radius: 0.625rem;
}
```

```tsx
function Card() {
  return <div className="rounded-[--radius] p-4">...</div>
}

function Button() {
  return <button className="rounded-[--radius] px-4">...</button>
}

function Input() {
  return <input className="rounded-[--radius] px-3" />
}
// Change --radius once, updates everywhere
```

**Note:** shadcn/ui components already use this pattern. When customizing, follow the same approach.

Reference: [shadcn/ui Theming](https://ui.shadcn.com/docs/theming)
