---
title: Use Container Queries Instead of Viewport Breakpoints for Components
impact: LOW-MEDIUM
impactDescription: makes components context-aware, eliminates parent-dependent breakpoints
tags: adopt, responsive, container-queries, layout
---

## Use Container Queries Instead of Viewport Breakpoints for Components

Viewport breakpoints couple a component's layout to the screen size, which breaks when the same component is placed in different containers (sidebar, modal, full-width). Container queries let the component respond to its own container's width, making it truly reusable. Tailwind v4 ships built-in container query support (`@sm`, `@md`, `@lg`, `@xl`, `@max-*`) with no plugin required.

**Incorrect (what's wrong):**

```html
<!-- Component uses viewport breakpoints — breaks when placed in a narrow sidebar -->
<div class="md:flex md:gap-4">
  <img class="md:w-1/3" />
  <div class="md:w-2/3">...</div>
</div>
```

**Correct (what's right):**

```html
<!-- Component adapts to its container's width, works anywhere -->
<div class="@container">
  <div class="@md:flex @md:gap-4">
    <img class="@md:w-1/3" />
    <div class="@md:w-2/3">...</div>
  </div>
</div>
```
