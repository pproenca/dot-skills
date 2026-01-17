---
title: Use @reference for CSS Module Integration
impact: MEDIUM-HIGH
impactDescription: eliminates duplicate CSS output in modules
tags: comp, reference, css-modules, vue, svelte
---

## Use @reference for CSS Module Integration

When using `@apply` in Vue/Svelte component styles or CSS modules, use `@reference` to import theme variables without duplicating CSS output.

**Incorrect (duplicates styles):**

```vue
<style scoped>
/* Imports entire stylesheet, duplicates in output */
@import "../styles/main.css";

.custom-button {
  @apply bg-brand-500 px-4 py-2 rounded;
}
</style>
```

**Correct (@reference for zero duplication):**

```vue
<style scoped>
/* References variables without emitting styles */
@reference "../styles/main.css";

.custom-button {
  @apply bg-brand-500 px-4 py-2 rounded;
}
</style>
```

**In CSS modules:**

```css
/* button.module.css */
@reference "../../styles/main.css";

.button {
  @apply bg-blue-500 text-white px-4 py-2 rounded;
}

.button:hover {
  @apply bg-blue-600;
}
```

**Benefits:**
- Access to theme variables and utilities
- Zero CSS duplication in output
- Works with scoped styles
- Proper cascade layer integration

Reference: [Tailwind CSS Functions and Directives](https://tailwindcss.com/docs/functions-and-directives)
