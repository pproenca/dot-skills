---
title: Keep an accessible focus indicator
tags: state, accessibility, focus
---

## Keep an accessible focus indicator

Removing the outline with `outline: none` to tidy up the look leaves keyboard users with no idea where focus is. Replace it with a clear `:focus-visible` ring, which shows for keyboard navigation but not on mouse clicks, so the page stays clean and operable.

**Incorrect (kills the focus indicator entirely):**

```css
.button:focus { outline: none; }
```

**Correct (a visible ring for keyboard focus only):**

```css
.button:focus-visible {
  outline: 2px solid hsl(221 83% 53%);
  outline-offset: 2px;
}
```

Reference: [MDN — :focus-visible](https://developer.mozilla.org/en-US/docs/Web/CSS/:focus-visible)
