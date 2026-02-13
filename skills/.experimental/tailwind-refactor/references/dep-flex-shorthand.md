---
title: Replace flex-shrink and flex-grow with shrink and grow
impact: HIGH
impactDescription: replaces 2 deprecated utilities with shorter equivalents
tags: dep, flex, layout
---

## Replace flex-shrink and flex-grow with shrink and grow

The `flex-shrink-*` and `flex-grow-*` utilities were deprecated in Tailwind v3.3 in favor of the shorter `shrink-*` and `grow-*` aliases. While both forms worked in v3, Tailwind CSS v4 removes the `flex-` prefixed versions entirely, causing build failures if they remain in your markup.

**Incorrect (what's wrong):**

```html
<div class="flex">
  <div class="flex-shrink-0">Logo</div>
  <div class="flex-grow">Content</div>
  <div class="flex-shrink flex-grow-0">Sidebar</div>
</div>
```

**Correct (what's right):**

```html
<div class="flex">
  <div class="shrink-0">Logo</div>
  <div class="grow">Content</div>
  <div class="shrink grow-0">Sidebar</div>
</div>
```
