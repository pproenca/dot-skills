---
title: Convert Sticky Elements to Static on Mobile
impact: HIGH
impactDescription: recovers 60 to 100px of vertical viewport on mobile
tags: layout, sticky, static, viewport, mobile
---

## Convert Sticky Elements to Static on Mobile

Sticky headers, toolbars, and sidebars consume fixed vertical space that is scarce on mobile screens. A 64px sticky header plus a 48px sticky toolbar already takes 112px from a 667px iPhone viewport -- that is 17% of the screen permanently unavailable for content. On desktop these elements improve navigation, but on mobile they should scroll with the page to maximize readable area.

**Incorrect (sticky elements that consume 30% of mobile viewport):**

```html
<div class="min-h-screen">
  <!-- 64px sticky header -->
  <header class="sticky top-0 z-30 border-b bg-white px-4 py-4">
    <div class="flex items-center justify-between">
      <h1 class="text-lg font-bold">Project Board</h1>
      <button class="rounded bg-blue-600 px-3 py-1.5 text-sm text-white">New Task</button>
    </div>
  </header>

  <!-- 48px sticky toolbar — stacks below the header -->
  <div class="sticky top-[64px] z-20 border-b bg-gray-50 px-4 py-3">
    <div class="flex gap-2">
      <button class="rounded border px-3 py-1 text-sm">All</button>
      <button class="rounded border px-3 py-1 text-sm">In Progress</button>
      <button class="rounded border px-3 py-1 text-sm">Done</button>
    </div>
  </div>

  <!-- Content area now starts 112px down and loses that space while scrolling -->
  <main class="p-4">
    <p class="text-gray-600">Your tasks will appear here.</p>
  </main>
</div>
```

**Correct (static on mobile, sticky on desktop):**

```html
<div class="min-h-screen">
  <!-- Scrolls naturally on mobile, sticks on lg screens -->
  <header class="static border-b bg-white px-4 py-4 lg:sticky lg:top-0 lg:z-30">
    <div class="flex items-center justify-between">
      <h1 class="text-lg font-bold">Project Board</h1>
      <button class="rounded bg-blue-600 px-3 py-1.5 text-sm text-white">New Task</button>
    </div>
  </header>

  <!-- Also static on mobile, sticky only on lg -->
  <div class="static border-b bg-gray-50 px-4 py-3 lg:sticky lg:top-[64px] lg:z-20">
    <div class="flex gap-2">
      <button class="rounded border px-3 py-1 text-sm">All</button>
      <button class="rounded border px-3 py-1 text-sm">In Progress</button>
      <button class="rounded border px-3 py-1 text-sm">Done</button>
    </div>
  </div>

  <!-- Full viewport available for content on mobile -->
  <main class="p-4">
    <p class="text-gray-600">Your tasks will appear here.</p>
  </main>
</div>
```

**Key principle:** Replace `sticky top-0` with `static lg:sticky lg:top-0`. The `static` keyword is the CSS default, so you can also simply omit positioning classes at the base level and only add `lg:sticky lg:top-0`. This returns the full viewport to content on mobile while keeping the navigation convenience on desktop.
