---
title: Use Slash Opacity Modifier
impact: HIGH
impactDescription: 50% fewer opacity-related classes
tags: util, opacity, modifier, colors, syntax
---

## Use Slash Opacity Modifier

Tailwind CSS v4 removes the deprecated opacity utilities (`bg-opacity-*`, `text-opacity-*`). Use the slash syntax for color opacity instead.

**Incorrect (deprecated opacity utilities):**

```html
<div class="bg-blue-500 bg-opacity-50">
  <!-- Deprecated in v4 -->
</div>

<p class="text-black text-opacity-75">
  <!-- Two classes for one effect -->
</p>
```

**Correct (slash opacity modifier):**

```html
<div class="bg-blue-500/50">
  <!-- Single class with opacity -->
</div>

<p class="text-black/75">
  <!-- Cleaner, more readable -->
</p>
```

**With CSS variables:**

```html
<div class="bg-(--brand-color)/50">
  <!-- Works with custom properties too -->
</div>
```

**Benefits:**
- Single class instead of two
- Works with any color utility
- Compatible with CSS variables
- More readable markup

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
