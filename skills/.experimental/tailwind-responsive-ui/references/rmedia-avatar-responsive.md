---
title: Scale Avatar Sizes Per Context and Breakpoint
impact: LOW-MEDIUM
impactDescription: maintains visual proportion in headers, lists, and profiles
tags: rmedia, avatar, sizing, context, responsive
---

## Scale Avatar Sizes Per Context and Breakpoint

Avatars at a single fixed size create visual imbalance — a `w-12 h-12` (48px) avatar dominates a compact mobile list item but feels tiny in a desktop profile header. Each context (list item, card, profile hero) needs its own base size, and each of those should scale across breakpoints. A list avatar might be 32px on mobile and 40px on desktop, while a profile avatar goes from 64px on mobile to 96px on desktop.

**Incorrect (one avatar size used in all contexts):**

```html
<!-- Same w-12 h-12 avatar everywhere — too large in the list, too small in the profile header -->
<div class="mx-auto max-w-2xl space-y-8 px-4 py-6">
  <!-- Profile header — avatar feels undersized next to the large heading -->
  <div class="flex items-center gap-4 border-b border-gray-200 pb-6">
    <img src="/avatars/sarah.jpg" alt="Sarah Chen" class="w-12 h-12 rounded-full" />
    <div>
      <h1 class="text-2xl font-bold text-gray-900">Sarah Chen</h1>
      <p class="text-gray-500">Senior Product Designer</p>
    </div>
  </div>
  <!-- Team member list — avatars crowd the compact rows -->
  <ul class="divide-y divide-gray-100">
    <li class="flex items-center gap-3 py-3">
      <img src="/avatars/james.jpg" alt="James Park" class="w-12 h-12 rounded-full" />
      <div>
        <p class="text-sm font-medium text-gray-900">James Park</p>
        <p class="text-xs text-gray-500">Engineering</p>
      </div>
    </li>
    <li class="flex items-center gap-3 py-3">
      <img src="/avatars/maria.jpg" alt="Maria Lopez" class="w-12 h-12 rounded-full" />
      <div>
        <p class="text-sm font-medium text-gray-900">Maria Lopez</p>
        <p class="text-xs text-gray-500">Marketing</p>
      </div>
    </li>
  </ul>
</div>
```

**Correct (avatar size varies by context and breakpoint):**

```html
<!-- Avatars sized per context: large in profile header, compact in list items, both scale per breakpoint -->
<div class="mx-auto max-w-2xl space-y-8 px-4 py-6">
  <!-- Profile header — w-16 on mobile, w-24 on desktop to match heading prominence -->
  <div class="flex items-center gap-4 border-b border-gray-200 pb-6 md:gap-6">
    <img src="/avatars/sarah.jpg" alt="Sarah Chen" class="w-16 h-16 md:w-24 md:h-24 rounded-full object-cover ring-2 ring-gray-100" />
    <div>
      <h1 class="text-2xl font-bold text-gray-900">Sarah Chen</h1>
      <p class="text-gray-500">Senior Product Designer</p>
    </div>
  </div>
  <!-- Team member list — w-8 on mobile, w-10 on desktop for compact rows -->
  <ul class="divide-y divide-gray-100">
    <li class="flex items-center gap-3 py-3">
      <img src="/avatars/james.jpg" alt="James Park" class="w-8 h-8 md:w-10 md:h-10 rounded-full object-cover" />
      <div>
        <p class="text-sm font-medium text-gray-900">James Park</p>
        <p class="text-xs text-gray-500">Engineering</p>
      </div>
    </li>
    <li class="flex items-center gap-3 py-3">
      <img src="/avatars/maria.jpg" alt="Maria Lopez" class="w-8 h-8 md:w-10 md:h-10 rounded-full object-cover" />
      <div>
        <p class="text-sm font-medium text-gray-900">Maria Lopez</p>
        <p class="text-xs text-gray-500">Marketing</p>
      </div>
    </li>
  </ul>
</div>
```

**Key principle:** Treat avatar sizing as context-dependent, not global. Profile headers need large avatars (`w-16 md:w-24`), list items need compact ones (`w-8 md:w-10`), and cards fall somewhere in between. Always add `object-cover` so non-square source images don't distort inside the circular crop.
