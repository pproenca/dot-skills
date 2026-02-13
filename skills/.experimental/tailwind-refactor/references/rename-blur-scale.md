---
title: Update Blur Utilities to New Scale
impact: HIGH
impactDescription: prevents wrong blur amounts
tags: rename, blur, backdrop-blur, scale
---

## Update Blur Utilities to New Scale

Tailwind CSS v4 shifted the blur scale down by one step, mirroring the same pattern as shadow utilities. Keeping the v3 class names results in a stronger blur than intended, which can make text unreadable or backgrounds overly obscured.

| v3 class | v4 class |
|---|---|
| `blur-sm` | `blur-xs` |
| `blur` | `blur-sm` |
| `backdrop-blur-sm` | `backdrop-blur-xs` |
| `backdrop-blur` | `backdrop-blur-sm` |

**Incorrect (what's wrong):**

```html
<div class="blur-sm">Subtle blur</div>
<div class="blur">Default blur</div>
<div class="backdrop-blur-sm">Subtle backdrop</div>
<div class="backdrop-blur">Default backdrop</div>
```

**Correct (what's right):**

```html
<div class="blur-xs">Subtle blur</div>
<div class="blur-sm">Default blur</div>
<div class="backdrop-blur-xs">Subtle backdrop</div>
<div class="backdrop-blur-sm">Default backdrop</div>
```
