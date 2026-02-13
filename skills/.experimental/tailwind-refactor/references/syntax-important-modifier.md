---
title: Use Trailing ! for Important Modifier
impact: MEDIUM
impactDescription: prevents removal when prefix ! syntax is dropped in future v4 release
tags: syntax, important, v4-migration, specificity
---

## Use Trailing ! for Important Modifier

Tailwind v4 moves the `!important` modifier from a prefix to a suffix position. The v3 prefix syntax (`!flex`) still works but is deprecated and will be removed in a future version. The suffix form (`flex!`) is the canonical v4 style and reads more naturally as "flex, importantly."

**Incorrect (what's wrong):**

```html
<!-- v3 prefix ! syntax (deprecated) -->
<div class="!flex !bg-red-500 !text-white">
  Prefix important
</div>
```

**Correct (what's right):**

```html
<!-- v4 suffix ! syntax -->
<div class="flex! bg-red-500! text-white!">
  Suffix important
</div>
```
