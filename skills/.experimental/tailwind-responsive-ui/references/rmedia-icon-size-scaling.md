---
title: Scale Icons Per Breakpoint, Not with Font Size
impact: MEDIUM
impactDescription: prevents oversized or undersized icons across screen sizes
tags: rmedia, icons, sizing, breakpoints, visual-hierarchy
---

## Scale Icons Per Breakpoint, Not with Font Size

From Refactoring UI: "Don't scale up icons designed for small sizes." Icons rendered at the wrong size look wrong — a 16px outline icon scaled to 48px appears spindly and fragile, while a 48px filled icon shrunk to 16px becomes an illegible blob. Instead of using one icon size everywhere, set explicit width and height at each breakpoint. On mobile, icons in navigation and list items should be compact; on desktop, they can afford more visual weight.

**Incorrect (single icon size used everywhere, too large on mobile):**

```html
<!-- w-12 h-12 (48px) icons dominate the layout on a 375px mobile screen -->
<nav class="flex items-center justify-between border-b border-gray-200 bg-white px-4 py-3">
  <a href="/" class="text-lg font-bold text-gray-900">AppName</a>
  <div class="flex items-center gap-4">
    <button class="relative text-gray-600 hover:text-gray-900">
      <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6 6 0 10-12 0v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0a3 3 0 11-6 0" />
      </svg>
      <span class="absolute -right-1 -top-1 flex h-4 w-4 items-center justify-center rounded-full bg-red-500 text-[10px] text-white">3</span>
    </button>
    <button class="text-gray-600 hover:text-gray-900">
      <svg class="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.066 2.573c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.573 1.066c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.066-2.573c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
      </svg>
    </button>
  </div>
</nav>
```

**Correct (icons sized independently per breakpoint):**

```html
<!-- w-5 h-5 (20px) on mobile, w-6 h-6 (24px) on desktop — proportional to surrounding elements -->
<nav class="flex items-center justify-between border-b border-gray-200 bg-white px-4 py-3">
  <a href="/" class="text-lg font-bold text-gray-900">AppName</a>
  <div class="flex items-center gap-3 md:gap-4">
    <button class="relative text-gray-600 hover:text-gray-900">
      <svg class="w-5 h-5 md:w-6 md:h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6 6 0 10-12 0v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0a3 3 0 11-6 0" />
      </svg>
      <span class="absolute -right-1 -top-1 flex h-4 w-4 items-center justify-center rounded-full bg-red-500 text-[10px] text-white">3</span>
    </button>
    <button class="text-gray-600 hover:text-gray-900">
      <svg class="w-5 h-5 md:w-6 md:h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.066 2.573c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.573 1.066c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.066-2.573c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
      </svg>
    </button>
  </div>
</nav>
```

**Key principle:** Size icons explicitly at each breakpoint (`w-5 h-5 md:w-6 md:h-6`) rather than using a single fixed size. If you need significantly larger icons at desktop, consider using a different icon variant (e.g., a filled version with more detail) rather than scaling up a stroke icon designed for 20px rendering.
