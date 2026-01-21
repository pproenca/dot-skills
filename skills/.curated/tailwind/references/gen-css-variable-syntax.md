---
title: Use Parentheses for CSS Variable References
impact: MEDIUM-HIGH
impactDescription: required v4 syntax, prevents build errors
tags: gen, variables, syntax, migration, css
---

## Use Parentheses for CSS Variable References

Tailwind CSS v4 changes the syntax for referencing CSS variables in utility classes from square brackets to parentheses.

**Incorrect (v3 square bracket syntax):**

```html
<div class="bg-[--brand-color]">
  <!-- v3 syntax - may not work in v4 -->
</div>

<div class="text-[--heading-size]">
  <!-- Square brackets for CSS variables -->
</div>
```

**Correct (v4 parentheses syntax):**

```html
<div class="bg-(--brand-color)">
  <!-- v4 syntax for CSS variables -->
</div>

<div class="text-(--heading-size)">
  <!-- Parentheses indicate variable reference -->
</div>
```

**Note:** Square brackets are still used for arbitrary static values:

```html
<div class="bg-[#ff5733]"><!-- Static arbitrary value --></div>
<div class="bg-(--custom-color)"><!-- CSS variable reference --></div>
```

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
