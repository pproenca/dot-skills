---
title: Use Explicit Border and Ring Colors
impact: HIGH
impactDescription: prevents invisible borders, ensures consistent appearance
tags: util, colors, borders, rings, defaults
---

## Use Explicit Border and Ring Colors

Tailwind CSS v4 changes default colors for borders and rings from `gray-200`/`blue-500` to `currentColor`. Always specify colors explicitly.

**Incorrect (relying on v3 defaults):**

```html
<div class="border px-4 py-3">
  <!-- Border may be invisible (currentColor vs gray-200) -->
</div>

<input class="ring" />
<!-- Ring color unpredictable -->
```

**Correct (explicit colors):**

```html
<div class="border border-gray-200 px-4 py-3">
  <!-- Explicit gray border -->
</div>

<input class="ring ring-blue-500" />
<!-- Explicit blue ring -->
```

**v4 default changes:**

| Property | v3 Default | v4 Default |
|----------|------------|------------|
| Border color | `gray-200` | `currentColor` |
| Ring color | `blue-500` | `currentColor` |
| Ring width | `3px` | `1px` |
| Placeholder | `gray-400` | `currentColor` at 50% |

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
