---
title: Use Responsive Holy Grail Layout with Grid
impact: HIGH
impactDescription: 3-column to 1-column reflow across 100% of screen sizes
tags: layout, grid, holy-grail, responsive, template
---

## Use Responsive Holy Grail Layout with Grid

The holy grail layout (header, left sidebar, main content, right sidebar, footer) is one of the most common page structures, but it requires careful responsive treatment. On mobile, all five regions must collapse into a single column. CSS Grid with named template areas makes this manageable, but in Tailwind the pragmatic approach is to combine grid column definitions with responsive ordering.

**Incorrect (complex grid that breaks on tablet and mobile):**

```html
<!-- Fixed 3-column layout — sidebars squeeze content on tablet, overlap on mobile -->
<div class="grid grid-cols-[250px_1fr_200px] grid-rows-[auto_1fr_auto] min-h-screen">
  <header class="col-span-3 border-b bg-white px-6 py-4">
    <h1 class="text-xl font-bold">My App</h1>
  </header>
  <aside class="border-r bg-gray-50 p-4">
    <nav class="space-y-2">
      <a href="#" class="block rounded px-3 py-2 text-sm">Dashboard</a>
      <a href="#" class="block rounded px-3 py-2 text-sm">Projects</a>
    </nav>
  </aside>
  <main class="overflow-y-auto p-6">
    <h2 class="text-lg font-semibold">Welcome back</h2>
    <p class="mt-2 text-gray-600">Here is your activity summary.</p>
  </main>
  <aside class="border-l bg-gray-50 p-4">
    <h3 class="text-sm font-semibold">Recent Activity</h3>
    <ul class="mt-2 space-y-1 text-sm text-gray-600">
      <li>Deployed v2.4.1</li>
      <li>Merged PR #482</li>
    </ul>
  </aside>
  <footer class="col-span-3 border-t bg-white px-6 py-3 text-sm text-gray-500">
    &copy; 2025 My App
  </footer>
</div>
```

**Correct (single column on mobile, full holy grail on lg+):**

```html
<!-- Stacks to single column on mobile, 3-column holy grail on lg -->
<div class="grid min-h-screen grid-cols-1 grid-rows-[auto_1fr_auto] lg:grid-cols-[250px_1fr_200px]">
  <header class="col-span-1 border-b bg-white px-4 py-4 lg:col-span-3 lg:px-6">
    <h1 class="text-xl font-bold">My App</h1>
  </header>

  <!-- Left sidebar: appears first in source for accessibility, reordered by grid on lg -->
  <aside class="border-b bg-gray-50 p-4 lg:row-start-2 lg:border-b-0 lg:border-r">
    <nav class="flex gap-2 overflow-x-auto lg:flex-col lg:gap-0 lg:space-y-2">
      <a href="#" class="shrink-0 rounded px-3 py-2 text-sm hover:bg-gray-200">Dashboard</a>
      <a href="#" class="shrink-0 rounded px-3 py-2 text-sm hover:bg-gray-200">Projects</a>
    </nav>
  </aside>

  <main class="overflow-y-auto p-4 lg:row-start-2 lg:p-6">
    <h2 class="text-lg font-semibold">Welcome back</h2>
    <p class="mt-2 text-gray-600">Here is your activity summary.</p>
  </main>

  <!-- Right sidebar: stacks below content on mobile -->
  <aside class="border-t bg-gray-50 p-4 lg:row-start-2 lg:border-l lg:border-t-0">
    <h3 class="text-sm font-semibold">Recent Activity</h3>
    <ul class="mt-2 space-y-1 text-sm text-gray-600">
      <li>Deployed v2.4.1</li>
      <li>Merged PR #482</li>
    </ul>
  </aside>

  <footer class="col-span-1 border-t bg-white px-4 py-3 text-sm text-gray-500 lg:col-span-3 lg:px-6">
    &copy; 2025 My App
  </footer>
</div>
```

**Key principle:** Define `grid-cols-1` as the mobile base and `lg:grid-cols-[250px_1fr_200px]` for desktop. Use `lg:col-span-3` on header and footer to span all columns only when they exist. Sidebars flow naturally in the single-column stack on mobile and slot into their grid positions on desktop via `lg:row-start-2`.
