---
title: Use @reference for @apply in Scoped Styles
impact: MEDIUM
impactDescription: fixes 100% of broken @apply in Vue/Svelte scoped styles
tags: arch, apply, scoped, vue, svelte, v4-migration
---

## Use @reference for @apply in Scoped Styles

In Tailwind v4, scoped stylesheets (Vue `<style scoped>`, Svelte `<style>`) do not have access to Tailwind's generated theme by default. This means `@apply` will fail silently or produce incorrect output inside scoped blocks. The `@reference` directive imports the theme without duplicating any styles in the output. Even better, use CSS variables directly to avoid `@apply` entirely.

**Incorrect (what's wrong):**

```vue
<style scoped>
/* Broken in v4 — scoped styles can't see Tailwind's theme */
h1 {
  @apply text-2xl font-bold text-red-500;
}
</style>
```

**Correct (what's right):**

```vue
<style scoped>
@reference "../../app.css";

h1 {
  @apply text-2xl font-bold text-red-500;
}
</style>
```

**Even better — use CSS variables directly:**

```vue
<style scoped>
h1 {
  color: var(--color-red-500);
  font-size: var(--text-2xl);
  font-weight: var(--font-weight-bold);
}
</style>
```
