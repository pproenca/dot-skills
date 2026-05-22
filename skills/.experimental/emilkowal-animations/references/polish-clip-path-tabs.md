---
title: Use clip-path for Aligned Tab Transitions
impact: MEDIUM
impactDescription: eliminates timing misalignment between highlight and text color
tags: polish, clip-path, tabs, transition, highlight
---

## Use clip-path for Aligned Tab Transitions

Instead of animating a highlight bar separately from text color changes, duplicate the tab list with different styling and use clip-path to reveal the active state.

**Incorrect (separate animations can misalign):**

```css
.tab-highlight {
  transition: left 200ms ease-out;
}
.tab-text {
  transition: color 200ms ease-out;
}
/* Timing misalignment visible in slow-motion */
```

**Correct (clip-path reveals both simultaneously):**

```css
.tabs-wrapper {
  position: relative;
}

.tabs-inactive {
  color: gray;
}

.tabs-active {
  position: absolute;
  top: 0;
  color: white;
  background: blue;
  clip-path: inset(0px 75% 0px 0% round 17px);
  transition: clip-path 200ms ease-out;
}

/* On tab change, update clip-path to reveal active tab */
```

This keeps the highlight and text in perfect sync because they change as a single unit.

Reference: [Animating with clip-path](https://emilkowal.ski/ui/the-magic-of-clip-path)
