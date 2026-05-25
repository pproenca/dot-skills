---
title: Use active:scale-[0.97] for Button Press Feedback in Tailwind v4
impact: MEDIUM
impactDescription: a 0.97 scale at ~150ms gives instant press feedback, and active: fires on touch where hover: does not in v4
tags: tw, tailwind, scale, active, press, feedback
---

## Use active:scale-[0.97] for Button Press Feedback in Tailwind v4

A subtle scale-down on press makes a control feel responsive. In Tailwind v4 `hover:` only applies on devices with a hover-capable pointer, so a hover-driven effect gives touch users no feedback—use `active:` for the press itself. The 0.97 value is not on the default scale, so it needs an arbitrary value; transforms compose automatically in v4, so no `transform` utility is required.

**Incorrect (hover-driven, wrong magnitude):**

```tsx
// hover: never fires on touch; scale-90 is too large for a press
<button className="transition-transform hover:scale-90">Save</button>
```

**Correct (active: press feedback at 0.97):**

```tsx
// Fires on both pointer and touch; lands in 150ms
<button className="transition-transform duration-150 ease-out active:scale-[0.97]">
  Save
</button>
```

**Notes:**
- Pair with `hover:` only for an additional resting-state hint, never as the sole feedback—see [`tw-reduced-motion`](tw-reduced-motion.md) to gate motion for sensitive users.

Reference: [Great Animations](https://emilkowal.ski/ui/great-animations)
