---
title: Update Border Radius Utilities to New Scale
impact: HIGH
impactDescription: prevents wrong border radius sizes
tags: rename, rounded, border-radius, scale
---

## Update Border Radius Utilities to New Scale

Tailwind CSS v4 shifted the border radius scale down by one step, just like shadow and blur utilities. The bare `rounded` class now maps to a smaller radius value, and `rounded-sm` becomes the new smallest step. Without updating, all rounded corners in your project render larger than designed.

| v3 class | v4 class |
|---|---|
| `rounded-sm` | `rounded-xs` |
| `rounded` | `rounded-sm` |

**Incorrect (what's wrong):**

```html
<button class="rounded-sm px-4 py-2">Subtle rounding</button>
<div class="rounded p-4">Default rounding</div>
```

**Correct (what's right):**

```html
<button class="rounded-xs px-4 py-2">Subtle rounding</button>
<div class="rounded-sm p-4">Default rounding</div>
```
