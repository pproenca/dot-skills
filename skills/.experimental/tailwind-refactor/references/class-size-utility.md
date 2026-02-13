---
title: Replace Matching w-* h-* with size-*
impact: HIGH
impactDescription: reduces class count by 50% for square elements
tags: class, size, width, height
---

## Replace Matching w-* h-* with size-*

When an element has identical width and height values, the `size-*` utility replaces both `w-*` and `h-*` in a single class. This cuts the class count in half for square elements like avatars, icons, and equal-dimension containers. Only apply this consolidation when the width and height values are exactly the same.

**Incorrect (what's wrong):**

```html
<img class="w-8 h-8" src="avatar.jpg" />
<div class="w-full h-full">Overlay</div>
<div class="w-screen h-screen">Full viewport</div>
```

**Correct (what's right):**

```html
<img class="size-8" src="avatar.jpg" />
<div class="size-full">Overlay</div>
<div class="size-screen">Full viewport</div>
```
