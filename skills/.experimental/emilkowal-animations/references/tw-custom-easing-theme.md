---
title: Register Custom Easing Curves as @theme Tokens in Tailwind v4
impact: MEDIUM
impactDescription: one @theme token replaces a repeated 30-character cubic-bezier across every call site, keeping curves consistent
tags: tw, tailwind, easing, theme, cubic-bezier, tokens
---

## Register Custom Easing Curves as @theme Tokens in Tailwind v4

Emil's signature curves (strong ease-out, on-screen ease-in-out, iOS drawer) are worth more than the built-in `ease-out`. Instead of repeating `ease-[cubic-bezier(...)]` at every call site—where a single transposed digit drifts the feel—define each curve once under the `--ease-*` theme namespace. Tailwind v4 generates a matching `ease-*` utility automatically.

**Incorrect (inline arbitrary curve, repeated):**

```tsx
// The same 30-character curve duplicated, easy to mistype
<div className="transition-transform duration-200 ease-[cubic-bezier(0.23,1,0.32,1)]" />
<div className="transition-transform duration-500 ease-[cubic-bezier(0.32,0.72,0,1)]" />
```

**Correct (define once in @theme, reference by name):**

```css
/* app.css */
@import "tailwindcss";

@theme {
  --ease-snappy: cubic-bezier(0.23, 1, 0.32, 1); /* strong ease-out for UI */
  --ease-onscreen: cubic-bezier(0.77, 0, 0.175, 1); /* on-screen movement */
  --ease-drawer: cubic-bezier(0.32, 0.72, 0, 1); /* iOS-style drawer/sheet */
}
```

```tsx
// Curves are named, consistent, and editable in one place
<div className="transition-transform duration-200 ease-snappy" />
<div className="transition-transform duration-500 ease-drawer" />
```

Reference: [Great Animations](https://emilkowal.ski/ui/great-animations)
