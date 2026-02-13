---
title: Replace top/right/bottom/left with inset-*
impact: HIGH
impactDescription: reduces 4 classes to 1 for positioned elements
tags: class, inset, position, shorthand
---

## Replace top/right/bottom/left with inset-*

When a positioned element sets all four sides to the same value, the `inset-*` utility replaces four separate classes with one. Similarly, `inset-x-*` replaces `left-*` and `right-*`, and `inset-y-*` replaces `top-*` and `bottom-*`. This reduces class noise significantly on overlay, modal, and full-bleed elements.

**Incorrect (what's wrong):**

```html
<div class="absolute top-0 right-0 bottom-0 left-0">Full overlay</div>
<div class="absolute left-0 right-0">Horizontal stretch</div>
<div class="absolute top-0 bottom-0">Vertical stretch</div>
```

**Correct (what's right):**

```html
<div class="absolute inset-0">Full overlay</div>
<div class="absolute inset-x-0">Horizontal stretch</div>
<div class="absolute inset-y-0">Vertical stretch</div>
```
