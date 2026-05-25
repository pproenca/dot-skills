---
title: Scope will-change-transform to the Active Gesture in Tailwind v4
impact: LOW-MEDIUM
impactDescription: drops idle compositor layers by binding will-change to a data-state instead of leaving it on every animated element
tags: tw, tailwind, will-change, performance, compositor, drag
---

## Scope will-change-transform to the Active Gesture in Tailwind v4

`will-change-transform` hints the browser to promote an element to its own compositor layer, which removes a 1px sub-pixel shift during transform animations. Leaving it on permanently keeps those layers alive at rest and consumes memory. Apply it only while the element is actually animating—bind it to the interaction state with a `data-*` variant—then drop it when the gesture ends.

**Incorrect (permanent promotion):**

```tsx
// Layer stays allocated even when the sheet is idle
<div className="will-change-transform transition-transform duration-300 ease-out" />
```

**Correct (scoped to the drag state):**

```tsx
// will-change only while data-dragging is set; gone at rest
<div
  data-dragging={isDragging}
  className="transition-transform duration-300 ease-out data-[dragging=true]:will-change-transform"
/>
```

**Notes:**
- Reach for this only after a measurable sub-pixel shift appears; promoting every element costs more than it saves.

Reference: [Great Animations](https://emilkowal.ski/ui/great-animations)
