---
title: Make Animations Origin-Aware
impact: HIGH
impactDescription: prevents popovers scaling from the wrong anchor point
tags: transform, transform-origin, dropdown, popover, radix
---

## Make Animations Origin-Aware

Dropdowns and popovers should animate from their trigger element, not from an arbitrary center point. Set transform-origin to match where the animation originates.

**Incorrect (default center origin):**

```css
.dropdown {
  transform-origin: center; /* Default */
  animation: scaleIn 200ms ease-out;
}
/* Dropdown scales from middle, disconnected from button */
```

**Correct (origin matches trigger):**

```css
.dropdown {
  transform-origin: top center; /* Matches button position */
  animation: scaleIn 200ms ease-out;
}
```

**With component libraries:**

```css
/* Radix UI */
.dropdown {
  transform-origin: var(--radix-dropdown-menu-content-transform-origin);
}

/* Base UI */
.popover {
  transform-origin: var(--transform-origin);
}
/* The library calculates the correct origin relative to the trigger */
```

shadcn/ui handles this automatically.

**When NOT to use this pattern:**
- **Modals.** Keep `transform-origin: center` on modals—they are not anchored to a trigger, they appear centered in the viewport, so scaling from a trigger point looks wrong.

Reference: [Good vs Great Animations](https://emilkowal.ski/ui/good-vs-great-animations)
