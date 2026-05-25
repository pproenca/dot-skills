---
title: Set transform-origin with origin-* Utilities in Tailwind v4
impact: LOW-MEDIUM
impactDescription: scales from the trigger edge instead of 50% off-center, so the surface reads as growing out of its anchor
tags: tw, tailwind, transform-origin, scale, origin, dropdown
---

## Set transform-origin with origin-* Utilities in Tailwind v4

A scale animation grows from its transform-origin. The default `center` makes a dropdown appear to inflate from its own middle, disconnected from the control that opened it. Match the origin to the anchor with an `origin-*` utility so the surface looks like it emerges from the trigger.

**Incorrect (default center origin):**

```tsx
// Menu anchored under a top-left button still scales from its center
<div className="scale-95 opacity-0 transition-[transform,opacity] duration-150 ease-out data-[open]:scale-100 data-[open]:opacity-100" />
```

**Correct (origin matched to the anchor):**

```tsx
// Grows out of the top-left corner, toward the menu body
<div className="origin-top-left scale-95 opacity-0 transition-[transform,opacity] duration-150 ease-out data-[open]:scale-100 data-[open]:opacity-100" />
```

**Notes:**
- Origin utilities cover all nine positions, e.g. `origin-top`, `origin-bottom-right`, `origin-left`; pick the one nearest the trigger.

Reference: [CSS Transforms](https://emilkowal.ski/ui/css-transforms)
