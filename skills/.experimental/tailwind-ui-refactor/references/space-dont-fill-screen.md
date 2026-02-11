---
title: Don't Fill the Whole Screen — Constrain Content Width
impact: HIGH
impactDescription: prevents 1400px-wide text blocks that destroy readability
tags: space, max-width, container, layout, responsive
---

Just because the viewport is 1920px wide doesn't mean your content should be 1920px wide. Give elements only the space they need. Wide screens need max-width constraints, not 100% widths everywhere.

**Incorrect (content stretches to fill all available space):**
```html
<div class="w-full px-4">
  <h1 class="text-3xl font-bold">Dashboard</h1>
  <p class="mt-4 text-gray-600">Welcome back. Here's what's happening with your projects today. You have several items that need attention and we want to make sure you see all of them clearly.</p>
  <div class="mt-6 grid grid-cols-4 gap-4">
    <!-- cards stretch across full 1920px -->
  </div>
</div>
```

**Correct (constrained, readable width):**
```html
<div class="mx-auto max-w-5xl px-6">
  <h1 class="text-3xl font-bold text-gray-900">Dashboard</h1>
  <p class="mt-4 max-w-2xl text-gray-600">Welcome back. Here's what's happening with your projects today.</p>
  <div class="mt-8 grid grid-cols-3 gap-6">
    <!-- cards at comfortable reading width -->
  </div>
</div>
```

Reference: Refactoring UI — "Layout and Spacing"
