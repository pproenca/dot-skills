---
title: Add Explicit Border Color for v4 Default Change
impact: HIGH
impactDescription: prevents borders changing from gray to currentColor
tags: class, border, color, default
---

## Add Explicit Border Color for v4 Default Change

In Tailwind CSS v3, the `border` utility implicitly set the border color to `gray-200`. In v4, the default border color changed to `currentColor`, matching standard CSS behavior. This means any element using `border` without an explicit color class will now inherit the text color as its border color, which can produce a dramatically different appearance. Adding an explicit `border-gray-200` preserves the original visual output without changing the design.

**Incorrect (what's wrong):**

```html
<div class="border p-4">
  Card with assumed gray border
</div>
```

**Correct (what's right):**

```html
<div class="border border-gray-200 p-4">
  Card with explicit gray border
</div>
```
