---
title: Gate Movement Behind motion-safe / motion-reduce in Tailwind v4
impact: MEDIUM
impactDescription: swaps transform for an opacity-only fallback for vestibular-sensitive users, leaving zero positional motion
tags: tw, tailwind, reduced-motion, accessibility, motion-safe, motion-reduce
---

## Gate Movement Behind motion-safe / motion-reduce in Tailwind v4

Opacity changes do not affect perceived position or size, so they are safe under `prefers-reduced-motion`, while transforms can trigger discomfort. Rather than removing animation entirely, keep a gentle fade: let the transform run only when motion is allowed, and fall back to an opacity transition otherwise. Tailwind's `motion-safe:` and `motion-reduce:` variants map straight to the media query.

**Incorrect (unconditional transform):**

```tsx
// Slides for everyone, including users who asked for reduced motion
<div className="transition-[transform,opacity] duration-300 ease-out translate-y-0 opacity-100" />
```

**Correct (transform only when safe, opacity fallback otherwise):**

```tsx
// motion-safe adds the slide; motion-reduce keeps a calm fade
<div className="opacity-100 transition-opacity duration-300 ease-out motion-safe:transition-[transform,opacity] motion-safe:translate-y-0" />
```

**Notes:**
- Prefer a softened alternative over `motion-reduce:transition-none`; a one-property fade still communicates state change without motion.

Reference: [Great Animations](https://emilkowal.ski/ui/great-animations)
