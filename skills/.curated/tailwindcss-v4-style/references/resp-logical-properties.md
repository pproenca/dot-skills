---
title: Use Logical Properties for RTL Support
impact: MEDIUM
impactDescription: automatic RTL support without duplicate styles
tags: resp, logical, rtl, ltr, internationalization
---

## Use Logical Properties for RTL Support

Use logical property utilities (`ms-`, `me-`, `ps-`, `pe-`) instead of physical properties (`ml-`, `mr-`, `pl-`, `pr-`) for automatic RTL layout support.

**Incorrect (physical properties):**

```html
<div class="ml-4 mr-8 pl-2 pr-6">
  <!-- Requires separate RTL styles -->
</div>

<div class="text-left">
  <!-- Doesn't flip in RTL -->
</div>
```

**Correct (logical properties):**

```html
<div class="ms-4 me-8 ps-2 pe-6">
  <!-- LTR: margin-left/right, padding-left/right -->
  <!-- RTL: automatically flips to match direction -->
</div>

<div class="text-start">
  <!-- LTR: text-align: left -->
  <!-- RTL: text-align: right -->
</div>
```

**Logical property mapping:**

| Physical | Logical | LTR | RTL |
|----------|---------|-----|-----|
| `ml-*` | `ms-*` | left | right |
| `mr-*` | `me-*` | right | left |
| `pl-*` | `ps-*` | left | right |
| `pr-*` | `pe-*` | right | left |
| `left-*` | `start-*` | left | right |
| `right-*` | `end-*` | right | left |
| `text-left` | `text-start` | left | right |
| `text-right` | `text-end` | right | left |

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)
