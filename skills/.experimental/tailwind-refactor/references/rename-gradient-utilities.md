---
title: Replace bg-gradient-* with bg-linear-*
impact: HIGH
impactDescription: prevents gradient rendering failures
tags: rename, gradient, bg-gradient, bg-linear
---

## Replace bg-gradient-* with bg-linear-*

Tailwind CSS v4 renamed all `bg-gradient-to-*` utilities to `bg-linear-to-*` to align with the CSS specification and to make room for new gradient types. The old `bg-gradient-*` classes no longer exist in v4 and will silently produce no output. In addition to the rename, v4 introduces `bg-conic-*` and `bg-radial-*` utilities, angle-based syntax like `bg-linear-45`, and color space modifiers such as `bg-linear-to-r/oklch` for perceptually smoother gradients.

**Incorrect (what's wrong):**

```html
<div class="bg-gradient-to-r from-blue-500 to-purple-600">
  Gradient banner
</div>
```

**Correct (what's right):**

```html
<div class="bg-linear-to-r from-blue-500 to-purple-600">
  Gradient banner
</div>
```
