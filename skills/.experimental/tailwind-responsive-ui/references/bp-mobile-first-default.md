---
title: Use Mobile-First Breakpoint Direction
impact: CRITICAL
impactDescription: 30 to 50% fewer responsive declarations
tags: bp, mobile-first, min-width, progressive-enhancement
---

## Use Mobile-First Breakpoint Direction

Mobile-first (min-width) means base styles cover the smallest screen, and you layer complexity upward. Tailwind's default breakpoints (`sm:`, `md:`, `lg:`) are already mobile-first, so your unsuffixed utilities become the mobile baseline. Fighting this direction with desktop-first overrides doubles your responsive declarations and introduces fragile `max-*` rules that break when new breakpoints are added.

**Incorrect (desktop-first with max-width overrides):**

```html
<!-- Base styles assume desktop, then override downward — doubles the work -->
<div class="max-[1024px]:flex-col max-[1024px]:px-4 max-[768px]:px-2 flex-row px-12 gap-8 max-[768px]:gap-4">
  <aside class="w-64 max-[1024px]:w-full max-[1024px]:border-b max-[1024px]:border-r-0 border-r border-gray-200">
    <nav class="flex max-[1024px]:flex-row flex-col gap-2 max-[768px]:gap-1">
      <a href="/dashboard" class="px-4 py-2 text-sm">Dashboard</a>
      <a href="/settings" class="px-4 py-2 text-sm">Settings</a>
    </nav>
  </aside>
  <main class="flex-1 max-[1024px]:pt-4">
    <h1 class="text-3xl max-[768px]:text-xl">Welcome back</h1>
  </main>
</div>
```

**Correct (mobile-first with progressive enhancement):**

```html
<!-- Base = mobile, layer complexity upward with sm:/md:/lg: -->
<div class="flex flex-col gap-4 px-2 md:flex-row md:gap-8 md:px-12">
  <aside class="w-full border-b border-gray-200 md:w-64 md:border-b-0 md:border-r">
    <nav class="flex flex-row gap-1 md:flex-col md:gap-2">
      <a href="/dashboard" class="px-4 py-2 text-sm">Dashboard</a>
      <a href="/settings" class="px-4 py-2 text-sm">Settings</a>
    </nav>
  </aside>
  <main class="flex-1 md:pt-0">
    <h1 class="text-xl md:text-3xl">Welcome back</h1>
  </main>
</div>
```

**Note:** This rule covers the full-page layout implications of mobile-first direction. See also `tailwind/resp-mobile-first` for the basic syntax pattern.
