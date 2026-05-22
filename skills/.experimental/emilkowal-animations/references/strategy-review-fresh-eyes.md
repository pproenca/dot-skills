---
title: Review Animations in Slow Motion and the Next Day
impact: MEDIUM
impactDescription: slow-mo 2–5× surfaces timing bugs invisible at full speed
tags: strategy, review, debugging, slow-motion, qa
---

## Review Animations in Slow Motion and the Next Day

Most animation flaws are invisible at full speed. Slow playback 2–5×, step frame-by-frame in DevTools, and re-review with fresh eyes the next day. Test gesture-driven animations on real hardware, not just a simulator.

**Incorrect (only ever viewed at full speed on the dev machine):**

```css
.feedback-button {
  transition: transform 160ms ease-out;
}
/* Origin, easing, and out-of-sync properties hide at 160ms */
```

**Correct (slow it down to inspect, then revert):**

```css
.feedback-button {
  transition: transform 1600ms ease-out; /* 10× slower while debugging only */
}
/* Or use DevTools → Animations to slow playback and step frame-by-frame */
```

What to look for in slow motion:
- Crossfades that show two overlapping states instead of one smooth blend
- Easing that starts or stops abruptly
- A `transform-origin` that scales from the wrong point
- `opacity`, `transform`, and `color` drifting out of sync

Reference: [7 Practical Animation Tips](https://emilkowal.ski/ui/7-practical-animation-tips)
