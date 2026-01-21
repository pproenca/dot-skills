---
title: Leverage Smart Utility Sorting
impact: MEDIUM
impactDescription: automatic cascade ordering, fewer specificity issues
tags: comp, sorting, cascade, specificity, utilities
---

## Leverage Smart Utility Sorting

Tailwind CSS v4 automatically sorts utilities by property count, ensuring complex utilities appear earlier in the CSS. This means you can override custom utilities with simple utilities.

**Incorrect (fighting specificity):**

```css
@utility button {
  @apply bg-black text-white px-4 py-2 rounded;
}
```

```html
<!-- Expecting bg-indigo-500 to override, but unsure about specificity -->
<button class="button bg-indigo-500">
  Click me
</button>
```

**Correct (trust smart sorting):**

```css
@utility button {
  @apply bg-black text-white px-4 py-2 rounded;
}
/* button has 5 properties, sorted BEFORE single-property utilities */
```

```html
<!-- bg-indigo-500 (1 property) comes AFTER button (5 properties) -->
<button class="button bg-indigo-500">
  <!-- Works: indigo background overrides black -->
  Click me
</button>
```

**How sorting works:**
1. Multi-property utilities sorted first (e.g., `button`)
2. Single-property utilities sorted after
3. Within same property count, alphabetical
4. Cascade layers handle component vs utility precedence

Reference: [Tailwind CSS Reusing Styles](https://tailwindcss.com/docs/reusing-styles)
