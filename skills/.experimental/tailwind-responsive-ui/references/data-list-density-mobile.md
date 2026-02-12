---
title: Increase List Item Density on Mobile
impact: LOW-MEDIUM
impactDescription: 100% more items visible per mobile screen
tags: data, lists, density, spacing, mobile-first
---

## Increase List Item Density on Mobile

Desktop list items can afford generous padding and full secondary details because users see 15-20 items at once in a tall viewport. On mobile, the same generous spacing means users see only 3-4 items per screen, forcing excessive scrolling through a list of 50+ results. Tightening padding and hiding secondary details on mobile doubles the visible item count, making lists scannable and reducing scroll fatigue.

**Incorrect (desktop-sized list items show only 3-4 per mobile screen):**

```html
<ul class="divide-y divide-gray-200">
  <li class="flex items-center gap-4 p-6">
    <img src="/avatars/sarah.jpg" alt="" class="h-12 w-12 rounded-full" />
    <div class="flex-1">
      <h3 class="text-base font-semibold text-gray-900">Sarah Chen</h3>
      <p class="text-sm text-gray-500">Engineering Lead</p>
      <p class="mt-1 text-sm text-gray-400">Last active 2 hours ago</p>
    </div>
    <div class="text-right">
      <p class="text-sm font-medium text-gray-900">12 projects</p>
      <p class="text-sm text-gray-500">San Francisco, CA</p>
    </div>
  </li>
  <li class="flex items-center gap-4 p-6">
    <img src="/avatars/marcus.jpg" alt="" class="h-12 w-12 rounded-full" />
    <div class="flex-1">
      <h3 class="text-base font-semibold text-gray-900">Marcus Johnson</h3>
      <p class="text-sm text-gray-500">Product Manager</p>
      <p class="mt-1 text-sm text-gray-400">Last active 5 minutes ago</p>
    </div>
    <div class="text-right">
      <p class="text-sm font-medium text-gray-900">8 projects</p>
      <p class="text-sm text-gray-500">New York, NY</p>
    </div>
  </li>
  <li class="flex items-center gap-4 p-6">
    <img src="/avatars/priya.jpg" alt="" class="h-12 w-12 rounded-full" />
    <div class="flex-1">
      <h3 class="text-base font-semibold text-gray-900">Priya Patel</h3>
      <p class="text-sm text-gray-500">Design Director</p>
      <p class="mt-1 text-sm text-gray-400">Last active yesterday</p>
    </div>
    <div class="text-right">
      <p class="text-sm font-medium text-gray-900">15 projects</p>
      <p class="text-sm text-gray-500">London, UK</p>
    </div>
  </li>
</ul>
```

**Correct (compact on mobile, generous on desktop):**

```html
<ul class="divide-y divide-gray-200">
  <li class="flex items-center gap-3 p-3 md:gap-4 md:p-6">
    <img src="/avatars/sarah.jpg" alt="" class="h-9 w-9 rounded-full md:h-12 md:w-12" />
    <div class="min-w-0 flex-1">
      <h3 class="truncate text-sm font-semibold text-gray-900 md:text-base">Sarah Chen</h3>
      <p class="truncate text-xs text-gray-500 md:text-sm">Engineering Lead</p>
      <!-- Secondary info hidden on mobile -->
      <p class="mt-1 hidden text-sm text-gray-400 md:block">Last active 2 hours ago</p>
    </div>
    <div class="hidden text-right md:block">
      <p class="text-sm font-medium text-gray-900">12 projects</p>
      <p class="text-sm text-gray-500">San Francisco, CA</p>
    </div>
    <!-- Compact badge visible on mobile only as a summary -->
    <span class="text-xs text-gray-400 md:hidden">12</span>
  </li>
  <li class="flex items-center gap-3 p-3 md:gap-4 md:p-6">
    <img src="/avatars/marcus.jpg" alt="" class="h-9 w-9 rounded-full md:h-12 md:w-12" />
    <div class="min-w-0 flex-1">
      <h3 class="truncate text-sm font-semibold text-gray-900 md:text-base">Marcus Johnson</h3>
      <p class="truncate text-xs text-gray-500 md:text-sm">Product Manager</p>
      <p class="mt-1 hidden text-sm text-gray-400 md:block">Last active 5 minutes ago</p>
    </div>
    <div class="hidden text-right md:block">
      <p class="text-sm font-medium text-gray-900">8 projects</p>
      <p class="text-sm text-gray-500">New York, NY</p>
    </div>
    <span class="text-xs text-gray-400 md:hidden">8</span>
  </li>
  <li class="flex items-center gap-3 p-3 md:gap-4 md:p-6">
    <img src="/avatars/priya.jpg" alt="" class="h-9 w-9 rounded-full md:h-12 md:w-12" />
    <div class="min-w-0 flex-1">
      <h3 class="truncate text-sm font-semibold text-gray-900 md:text-base">Priya Patel</h3>
      <p class="truncate text-xs text-gray-500 md:text-sm">Design Director</p>
      <p class="mt-1 hidden text-sm text-gray-400 md:block">Last active yesterday</p>
    </div>
    <div class="hidden text-right md:block">
      <p class="text-sm font-medium text-gray-900">15 projects</p>
      <p class="text-sm text-gray-500">London, UK</p>
    </div>
    <span class="text-xs text-gray-400 md:hidden">15</span>
  </li>
</ul>
```

**Key principle:** Use `p-3 md:p-6` and `gap-3 md:gap-4` to tighten spacing on mobile. Hide secondary details with `hidden md:block` and reduce avatar sizes with `h-9 w-9 md:h-12 md:w-12`. Add `min-w-0` on flex children to enable `truncate` to work properly, preventing text from blowing out the layout.
