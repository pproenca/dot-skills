---
title: Collapse Sidebar to Top or Bottom on Mobile
impact: CRITICAL
impactDescription: recovers 200 to 300px horizontal space on mobile
tags: layout, sidebar, collapse, responsive, navigation
---

## Collapse Sidebar to Top or Bottom on Mobile

Sidebars consume 200-300px of horizontal space that simply does not exist on a 375px mobile screen. Keeping a sidebar visible on mobile squeezes main content into an unusable 75-175px column. Collapse the sidebar into the normal document flow on mobile so it sits above or below the main content as a full-width section.

**Incorrect (sidebar persists on mobile, squeezing main content):**

```html
<!-- On a 375px screen the sidebar takes 250px, leaving only 125px for content -->
<div class="flex flex-row">
  <aside class="w-[250px] shrink-0 border-r bg-gray-50 p-4">
    <nav>
      <h2 class="mb-4 font-semibold">Dashboard</h2>
      <a href="/overview" class="block rounded px-3 py-2 text-sm hover:bg-gray-200">Overview</a>
      <a href="/analytics" class="block rounded px-3 py-2 text-sm hover:bg-gray-200">Analytics</a>
      <a href="/reports" class="block rounded px-3 py-2 text-sm hover:bg-gray-200">Reports</a>
      <a href="/settings" class="block rounded px-3 py-2 text-sm hover:bg-gray-200">Settings</a>
    </nav>
  </aside>
  <main class="flex-1 p-6">
    <h1 class="text-2xl font-bold">Analytics Dashboard</h1>
    <p class="mt-2 text-gray-600">Your performance metrics at a glance.</p>
  </main>
</div>
```

**Correct (sidebar collapses to full-width section above content on mobile):**

```html
<!-- Sidebar stacks above content on mobile, sits beside it on lg screens -->
<div class="flex flex-col lg:flex-row">
  <aside class="w-full border-b bg-gray-50 p-4 lg:w-[250px] lg:shrink-0 lg:border-b-0 lg:border-r">
    <nav>
      <h2 class="mb-3 font-semibold lg:mb-4">Dashboard</h2>
      <!-- Horizontal scroll on mobile, vertical list on desktop -->
      <div class="flex gap-2 overflow-x-auto lg:flex-col lg:gap-0">
        <a href="/overview" class="shrink-0 rounded px-3 py-2 text-sm hover:bg-gray-200">Overview</a>
        <a href="/analytics" class="shrink-0 rounded px-3 py-2 text-sm hover:bg-gray-200">Analytics</a>
        <a href="/reports" class="shrink-0 rounded px-3 py-2 text-sm hover:bg-gray-200">Reports</a>
        <a href="/settings" class="shrink-0 rounded px-3 py-2 text-sm hover:bg-gray-200">Settings</a>
      </div>
    </nav>
  </aside>
  <main class="flex-1 p-4 lg:p-6">
    <h1 class="text-2xl font-bold">Analytics Dashboard</h1>
    <p class="mt-2 text-gray-600">Your performance metrics at a glance.</p>
  </main>
</div>
```

**Key principle:** Use `flex-col lg:flex-row` on the container and `w-full lg:w-[250px]` on the sidebar. The sidebar becomes a horizontal nav strip or stacked section on mobile, only becoming a fixed-width column when the viewport is wide enough.
