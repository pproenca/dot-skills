---
title: Use ease-out as Your Default Easing
impact: CRITICAL
impactDescription: ease-out at 200ms feels faster than ease-in at the same 200ms
tags: ease, easing, ease-out, transitions, responsiveness
---

## Use ease-out as Your Default Easing

The ease-out curve starts fast and slows at the end, creating an impression of quick response while maintaining smooth transitions. This mimics how objects naturally decelerate.

**Incorrect (linear easing feels robotic):**

```css
.modal {
  transition: opacity 200ms linear, transform 200ms linear;
}
/* Animation feels mechanical and disconnected */
```

**Correct (ease-out feels responsive):**

```css
.modal {
  transition: opacity 200ms ease-out, transform 200ms ease-out;
}
/* Starts fast, giving immediate feedback, then settles smoothly */
```

**When to use ease-out:**
- Enter and exit animations
- User-initiated interactions (dropdowns, modals, tooltips)
- Any element responding to user action

**Never use `ease-in` for UI.** It starts slow, delaying the exact moment the user is watching most closely, so the interface feels sluggish. A dropdown with `ease-in` at 300ms *feels* slower than `ease-out` at the same 300ms. `ease-in` is the more common mistake than `linear`—reach for `ease-out` (or a custom curve) instead.

Reference: [Great Animations](https://emilkowal.ski/ui/great-animations)
