---
title: Use Trailing Important Modifier
impact: HIGH
impactDescription: prevents v4 syntax errors
tags: util, important, modifier, syntax, migration
---

## Use Trailing Important Modifier

Tailwind CSS v4 moves the important modifier (`!`) from the beginning to the end of utility classes for better readability.

**Incorrect (v3 leading modifier):**

```html
<div class="!flex !bg-red-500 !p-4">
  <!-- Leading exclamation marks -->
</div>
```

**Correct (v4 trailing modifier):**

```html
<div class="flex! bg-red-500! p-4!">
  <!-- Trailing exclamation marks -->
</div>
```

**Benefits of trailing modifier:**
- Reads left-to-right naturally
- Easier to spot important overrides
- Consistent with other modifier patterns

**With variants:**

```html
<!-- v3 -->
<div class="!hover:bg-blue-500">

<!-- v4 -->
<div class="hover:bg-blue-500!">
```

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
