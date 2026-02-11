---
title: Avoid Viewport-Relative Units for Element Sizing
impact: MEDIUM-HIGH
impactDescription: prevents components from becoming unreadable at extreme viewport sizes
tags: space, sizing, responsive, viewport-units, breakpoints
---

Sizing elements with viewport-relative units (`vw`) makes them too small on mobile and too large on desktop. Use explicit Tailwind sizing classes that scale independently at different breakpoints. This does not apply to `rem` units, which Tailwind uses by default and scale well with user font-size preferences.

**Incorrect (relative sizing creates extremes):**
```html
<div class="p-[2vw]">
  <h1 class="text-[3vw] font-bold">Welcome</h1>
  <p class="mt-[1vw] text-[1.5vw]">Your dashboard overview</p>
  <button class="mt-[2vw] rounded bg-blue-600 px-[2vw] py-[1vw] text-[1.2vw] text-white">Get Started</button>
</div>
```

**Correct (explicit, breakpoint-adjusted sizes):**
```html
<div class="p-4 md:p-6 lg:p-8">
  <h1 class="text-2xl font-bold md:text-3xl lg:text-4xl">Welcome</h1>
  <p class="mt-2 text-sm text-gray-600 md:text-base">Your dashboard overview</p>
  <button class="mt-4 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white md:px-5 md:py-2.5 md:text-base">Get Started</button>
</div>
```

Reference: Refactoring UI — "Layout and Spacing"
