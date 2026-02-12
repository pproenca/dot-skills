---
title: Ensure Minimum 44px Touch Targets on Mobile
impact: MEDIUM
impactDescription: meets WCAG 2.5.8 — reduces mis-taps by 50%+
tags: touch, accessibility, wcag, mobile, buttons
---

## Ensure Minimum 44px Touch Targets on Mobile

WCAG 2.5.8 (Level AA) requires interactive elements to have at least a 24x24px target; WCAG 2.5.5 (Level AAA) recommends 44x44px. This rule targets the stricter 44px standard for comfortable touch interaction. Small icon buttons and tightly packed links are the leading cause of mis-taps on mobile devices, forcing users to zoom in or repeatedly tap to hit their target. Enforcing a minimum touch area on mobile while keeping compact sizing on desktop gives both audiences an optimal experience.

**Incorrect (icon button too small for comfortable mobile tapping):**

```html
<!-- 24px total (p-1 + w-6/h-6) — meets bare minimum but users mis-tap frequently -->
<button class="rounded p-1" aria-label="Close dialog">
  <svg class="h-6 w-6 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
  </svg>
</button>

<nav class="flex gap-1">
  <!-- Links are only as tall as their text — ~20px tap target -->
  <a href="/home" class="px-2 py-0.5 text-sm text-blue-600">Home</a>
  <a href="/about" class="px-2 py-0.5 text-sm text-blue-600">About</a>
  <a href="/contact" class="px-2 py-0.5 text-sm text-blue-600">Contact</a>
</nav>
```

**Correct (44px minimum on mobile, compact on desktop):**

```html
<!-- min-h/min-w enforce 44px touch area on mobile, removed at md for compact desktop UI -->
<button
  class="inline-flex min-h-[44px] min-w-[44px] items-center justify-center rounded p-2 md:min-h-0 md:min-w-0 md:p-1"
  aria-label="Close dialog"
>
  <svg class="h-6 w-6 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
  </svg>
</button>

<nav class="flex gap-1">
  <!-- 44px minimum height on mobile via min-h and padding, relaxed on desktop -->
  <a href="/home" class="inline-flex min-h-[44px] items-center px-3 py-2 text-sm text-blue-600 md:min-h-0 md:px-2 md:py-0.5">Home</a>
  <a href="/about" class="inline-flex min-h-[44px] items-center px-3 py-2 text-sm text-blue-600 md:min-h-0 md:px-2 md:py-0.5">About</a>
  <a href="/contact" class="inline-flex min-h-[44px] items-center px-3 py-2 text-sm text-blue-600 md:min-h-0 md:px-2 md:py-0.5">Contact</a>
</nav>
```
