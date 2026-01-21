---
title: Use Dynamic Utility Values
impact: HIGH
impactDescription: eliminates arbitrary value syntax, cleaner markup
tags: gen, utilities, dynamic, spacing, grid
---

## Use Dynamic Utility Values

Tailwind CSS v4 supports dynamic values for many utilities without arbitrary value syntax. Grid columns, spacing, and other utilities accept any numeric value.

**Incorrect (arbitrary value syntax):**

```html
<div class="grid grid-cols-[15]">
  <!-- Arbitrary syntax for non-standard column count -->
</div>

<div class="mt-[68px] w-[340px]">
  <!-- Arbitrary pixel values -->
</div>
```

**Correct (dynamic utility values):**

```html
<div class="grid grid-cols-15">
  <!-- Any column count works natively -->
</div>

<div class="mt-17 w-85">
  <!-- Calculated from spacing scale: var(--spacing) * N -->
</div>
```

**How it works:**

```css
/* Generated CSS */
.mt-17 { margin-top: calc(var(--spacing) * 17); }
.w-85 { width: calc(var(--spacing) * 85); }
.grid-cols-15 { grid-template-columns: repeat(15, minmax(0, 1fr)); }
```

**Benefits:**
- Cleaner class names
- Consistent spacing scale
- Better readability
- Fewer arbitrary values in markup

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)
