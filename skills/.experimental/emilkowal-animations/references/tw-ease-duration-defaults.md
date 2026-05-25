---
title: Set ease-out and a Sub-300ms Duration Explicitly in Tailwind v4
impact: MEDIUM-HIGH
impactDescription: ease-out at 200ms reads faster than v4's default ease-in-out curve, and scoping the property to transform/opacity avoids per-frame layout
tags: tw, tailwind, easing, duration, transition, ease-out
---

## Set ease-out and a Sub-300ms Duration Explicitly in Tailwind v4

`transition-all` animates every changed property—including layout properties like `width` and `top`—and falls back to Tailwind's default timing function (`cubic-bezier(0.4, 0, 0.2, 1)`, an ease-in-out). For UI, scope the transition to `transform` and `opacity`, set `ease-out`, and keep the duration under 300ms so the motion feels like a quick response rather than a slow settle.

**Incorrect (transition-all + default curve):**

```tsx
// Animates layout props on any change and uses the default ease-in-out curve
<div className="transition-all duration-300" />
```

**Correct (compositor-only properties + explicit ease-out):**

```tsx
// Only transform and opacity animate; ease-out at 200ms feels responsive
<div className="transition-[transform,opacity] duration-200 ease-out" />
```

**Notes:**
- `transition-transform`, `transition-opacity`, and `transition-colors` are narrower built-ins when you animate a single property group.
- Reserve durations of 300–500ms for large surfaces (modals, drawers); see [`tw-asymmetric-timing`](tw-asymmetric-timing.md) for press/release splits.

Reference: [Great Animations](https://emilkowal.ski/ui/great-animations)
