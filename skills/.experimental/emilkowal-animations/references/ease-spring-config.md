---
title: Configure Springs with Duration and Bounce
impact: HIGH
impactDescription: preserves velocity on interrupt; keeps UI bounce subtle
tags: ease, spring, framer-motion, motion, bounce, physics
---

## Configure Springs with Duration and Bounce

Apple's `duration` + `bounce` model is far easier to reason about than raw `stiffness`/`damping`/`mass`. Keep bounce subtle (0.1–0.3) for UI, and reserve visible bounce for drag-to-dismiss or playful moments. Springs also preserve velocity when interrupted, while CSS transitions and keyframes restart from zero—so a spring reverses smoothly mid-gesture.

**Incorrect (opaque physics params, overshoots):**

```tsx
<motion.div
  animate={{ y: 0 }}
  transition={{ type: 'spring', stiffness: 700, damping: 15 }}
/>
// stiffness/damping are hard to tune by intuition; this overshoots wildly
```

**Correct (duration + bounce, easy to reason about):**

```tsx
<motion.div
  animate={{ y: 0 }}
  transition={{ type: 'spring', duration: 0.5, bounce: 0.2 }}
/>
// bounce stays subtle; if the user grabs it mid-animation, velocity carries over
```

**Alternative (need fine physical control):**
Use `{ type: 'spring', mass: 1, stiffness: 100, damping: 10 }` only when you need precise physical behaviour the duration/bounce model can't express.

**When NOT to use this pattern:**
- Speed-critical functional UI (data entry, banking flows) where a fixed-duration ease-out is faster and calmer
- Any animation a user triggers hundreds of times a day

Reference: [Great Animations](https://emilkowal.ski/ui/great-animations)
