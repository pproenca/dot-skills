---
title: Don't Force Everything Into a Grid — Use Fixed Widths
impact: HIGH
impactDescription: prevents awkwardly stretched sidebars and form fields
tags: space, grid, layout, fixed-width, flexible
---

Not everything needs to live in a flexible grid. Sidebars, form fields, and fixed-content areas work better with fixed widths. Stretching a 200px sidebar to fill 25% of a 2560px screen looks wrong.

**Incorrect (sidebar stretches with grid):**
```html
<div class="grid grid-cols-4 gap-6">
  <aside class="col-span-1 rounded-lg bg-gray-50 p-4">
    <!-- sidebar stretches to 25% of any viewport -->
    <nav class="space-y-2">
      <a class="block text-sm text-gray-700">Dashboard</a>
      <a class="block text-sm text-gray-700">Settings</a>
    </nav>
  </aside>
  <main class="col-span-3">
    <!-- content area -->
  </main>
</div>
```

**Correct (fixed sidebar, flexible content):**
```html
<div class="flex gap-8">
  <aside class="w-56 shrink-0 rounded-lg bg-gray-50 p-4">
    <nav class="space-y-2">
      <a class="block text-sm text-gray-700">Dashboard</a>
      <a class="block text-sm text-gray-700">Settings</a>
    </nav>
  </aside>
  <main class="min-w-0 flex-1">
    <!-- content takes remaining space -->
  </main>
</div>
```

Reference: Refactoring UI — "Layout and Spacing"
