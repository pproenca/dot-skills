---
title: Use ease-out with a custom curve for UI transitions
tags: motion, easing, animation
---

## Use ease-out with a custom curve for UI transitions

`ease-in` (and `transition: all` on the default curve) starts slowly, so the interface feels sluggish at the exact moment the user is watching most closely; the built-in curves are also too weak to feel intentional. Use `ease-out` with a stronger custom cubic-bezier, and name the properties you animate.

**Incorrect (ease-in on an entering element, and animates everything):**

```css
.dropdown { transition: all 200ms ease-in; }
```

**Correct (ease-out custom curve on explicit properties):**

```css
.dropdown {
  transition: opacity 180ms cubic-bezier(0.23, 1, 0.32, 1),
              transform 180ms cubic-bezier(0.23, 1, 0.32, 1);
}
```

Reference: [Emil Kowalski — Great animations](https://emilkowal.ski/ui/great-animations)
