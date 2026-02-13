---
title: Update CSS Variable Syntax from Brackets to Parentheses
impact: MEDIUM
impactDescription: prevents broken variable references
tags: syntax, css-variables, v4-migration
---

## Update CSS Variable Syntax from Brackets to Parentheses

Tailwind v4 changed the arbitrary CSS variable syntax from square brackets to parentheses. Square brackets still work for non-variable arbitrary values like `bg-[#ff0000]`, but CSS custom properties now use the parenthesis form. Using the old syntax may produce warnings and will eventually be removed.

**Incorrect (what's wrong):**

```html
<!-- v3 bracket syntax for CSS variables -->
<div class="bg-[--brand-color] text-[--heading-color] border-[--border-color]">
  Old variable syntax
</div>
```

**Correct (what's right):**

```html
<!-- v4 parenthesis syntax for CSS variables -->
<div class="bg-(--brand-color) text-(--heading-color) border-(--border-color)">
  New variable syntax
</div>
```
