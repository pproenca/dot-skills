---
title: Gate Hover Animations Behind a Pointer Media Query
impact: MEDIUM
impactDescription: prevents hover animations firing on tap on touch devices
tags: interact, hover, touch, media-query, pointer
---

## Gate Hover Animations Behind a Pointer Media Query

Touch devices fire `:hover` on tap and leave it stuck until the user taps elsewhere. Gate hover-only animations behind `@media (hover: hover) and (pointer: fine)` so they apply only to devices with a real, precise pointer.

**Incorrect (hover fires on tap):**

```css
.card:hover {
  transform: scale(1.05);
}
/* On touch, a tap triggers :hover and the card stays scaled until you tap away */
```

**Correct (gated to fine pointers):**

```css
@media (hover: hover) and (pointer: fine) {
  .card:hover {
    transform: scale(1.05);
  }
}
/* Mouse users get the hover; touch users get a clean tap */
```

Reference: [Great Animations](https://emilkowal.ski/ui/great-animations)
