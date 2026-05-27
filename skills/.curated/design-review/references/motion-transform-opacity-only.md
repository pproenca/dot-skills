---
title: Animate only transform and opacity
tags: motion, performance, animation
---

## Animate only transform and opacity

Animating layout properties like `height`, `width`, `top`, or `margin` forces the browser to recalculate layout and repaint on every frame, which drops frames on lower-end devices. Animate `transform` and `opacity` instead — they run on the compositor and stay smooth.

**Incorrect (animates a layout property — janky):**

```css
.drawer { transition: height 300ms ease-out; }
```

**Correct (animates transform — composited):**

```css
.drawer { transition: transform 300ms cubic-bezier(0.32, 0.72, 0, 1); }
.drawer[data-state="closed"] { transform: translateY(100%); }
```

Reference: [Emil Kowalski — CSS transforms](https://emilkowal.ski/ui/css-transforms)
