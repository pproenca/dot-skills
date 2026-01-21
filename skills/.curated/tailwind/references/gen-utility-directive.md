---
title: Use @utility for Custom Utilities
impact: HIGH
impactDescription: enables variant support, proper sorting
tags: gen, utility, custom, directive, variants
---

## Use @utility for Custom Utilities

Define custom utilities with `@utility` instead of `@layer utilities`. This enables automatic variant support and proper cascade layer sorting.

**Incorrect (legacy @layer approach):**

```css
@layer utilities {
  .scrollbar-hide {
    -ms-overflow-style: none;
    scrollbar-width: none;
  }
  .scrollbar-hide::-webkit-scrollbar {
    display: none;
  }
}
/* No automatic variant support */
```

**Correct (v4 @utility directive):**

```css
@utility scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
  &::-webkit-scrollbar {
    display: none;
  }
}
/* Automatically works with hover:, focus:, md:, etc. */
```

```html
<div class="scrollbar-hide hover:scrollbar-default">
  <!-- Variants work automatically -->
</div>
```

**Benefits:**
- Automatic variant support (hover, focus, responsive)
- Proper cascade layer ordering
- Smart specificity sorting
- Consistent with built-in utilities

Reference: [Tailwind CSS Functions and Directives](https://tailwindcss.com/docs/functions-and-directives)
