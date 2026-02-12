---
title: Prefer Removing a Wrapper Over Adding 5 Utility Classes to It
impact: HIGH
impactDescription: cuts class count 20-30% per component by eliminating unnecessary DOM nesting
tags: intent, simplify, remove-wrappers, flat-markup, less-is-more
---

When a component looks wrong, the reflex is to add classes: rounded corners, shadows, borders, background colors. But often the real fix is structural — remove a wrapper div, merge two elements into one, or collapse a nested structure. Every div you remove eliminates its entire class list.

**Incorrect (adding styling to fix nested layout issues):**
```html
<div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
  <div class="mb-4 border-b border-gray-100 pb-4">
    <div class="flex items-center gap-3">
      <div class="flex h-10 w-10 items-center justify-center rounded-full bg-blue-100">
        <svg class="h-5 w-5 text-blue-600"><!-- icon --></svg>
      </div>
      <div>
        <h3 class="text-base font-semibold text-gray-900">New Message</h3>
        <p class="text-sm text-gray-500">From support team</p>
      </div>
    </div>
  </div>
  <div class="text-sm leading-relaxed text-gray-600">
    <p>Your request has been received.</p>
  </div>
</div>
```

**Correct (flatten structure, remove unnecessary wrappers):**
```html
<div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
  <h3 class="text-base font-semibold text-gray-900">New Message</h3>
  <p class="mt-1 text-sm text-gray-500">From support team</p>
  <p class="mt-4 text-sm leading-relaxed text-gray-600">Your request has been received.</p>
</div>
```

Count the DOM depth. If a component is 4+ levels deep, look for wrappers that exist only for styling. Remove them and let the remaining elements handle their own spacing.

Reference: Refactoring UI — "Start with a Feature, Not a Layout"
