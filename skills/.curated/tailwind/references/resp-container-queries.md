---
title: Use Container Queries for Component-Level Responsiveness
impact: MEDIUM
impactDescription: eliminates viewport-dependent component bugs
tags: resp, container-queries, components, responsive, layout
---

## Use Container Queries for Component-Level Responsiveness

Use built-in container queries (`@container`, `@sm:`, `@lg:`) for components that should adapt to their container size, not viewport size.

**Incorrect (viewport-based component):**

```html
<aside class="w-full lg:w-80">
  <!-- Card adapts to viewport, not sidebar width -->
  <div class="p-4 lg:p-6">
    <h3 class="text-lg lg:text-xl">Title</h3>
    <p class="text-sm lg:text-base">Description</p>
  </div>
</aside>
```

**Correct (container-based component):**

```html
<aside class="w-full lg:w-80 @container">
  <!-- Card adapts to sidebar width -->
  <div class="p-4 @lg:p-6">
    <h3 class="text-lg @lg:text-xl">Title</h3>
    <p class="text-sm @lg:text-base">Description</p>
  </div>
</aside>
```

**Container query variants:**

```html
<!-- Min-width queries (default) -->
<div class="@sm:flex @lg:grid">

<!-- Max-width queries -->
<div class="@max-md:hidden">

<!-- Range queries -->
<div class="@min-sm:@max-lg:flex">
```

**When to use container queries:**
- Cards in variable-width layouts
- Sidebar components
- Reusable UI components
- Components in grid/flex containers

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)
