---
title: Match Motion to the Component's Personality
impact: MEDIUM
impactDescription: prevents mismatched motion that reads as generic and off-brand
tags: strategy, cohesion, easing, personality, brand
---

## Match Motion to the Component's Personality

Animation values should fit the personality of what they animate. A playful product can be bouncier; a professional dashboard should be crisp and fast. Sonner feels satisfying partly because its motion is cohesive—slightly slower and using `ease` rather than `ease-out` to read as elegant, matching its design and pacing.

**Incorrect (generic curve fights the mood):**

```css
.toast {
  transition: transform 150ms ease-out; /* crisp, like a dashboard control */
}
/* Reads as abrupt against a relaxed, elegant product */
```

**Correct (motion matches the product's mood):**

```css
.toast {
  transition: transform 400ms ease; /* slightly slower + plain ease = elegant */
}
/* Motion, visual design, and pacing all feel like one coherent system */
```

Reference: [Building a Toast Component](https://emilkowal.ski/ui/building-a-toast-component)
