---
title: Update Shadow Utilities to New Scale
impact: HIGH
impactDescription: prevents wrong shadow sizes across project
tags: rename, shadow, drop-shadow, scale
---

## Update Shadow Utilities to New Scale

Tailwind CSS v4 shifted the entire shadow scale down by one step, inserting a new smallest size at each end. If you keep the v3 class names, every shadow in your project renders one size larger than intended. The same shift applies to both `shadow-*` and `drop-shadow-*` utilities.

| v3 class | v4 class |
|---|---|
| `shadow-sm` | `shadow-xs` |
| `shadow` | `shadow-sm` |
| `drop-shadow-sm` | `drop-shadow-xs` |
| `drop-shadow` | `drop-shadow-sm` |

**Incorrect (what's wrong):**

```html
<div class="shadow-sm">Subtle card shadow</div>
<div class="shadow">Default card shadow</div>
<div class="drop-shadow-sm">Subtle image shadow</div>
<div class="drop-shadow">Default image shadow</div>
```

**Correct (what's right):**

```html
<div class="shadow-xs">Subtle card shadow</div>
<div class="shadow-sm">Default card shadow</div>
<div class="drop-shadow-xs">Subtle image shadow</div>
<div class="drop-shadow-sm">Default image shadow</div>
```
