---
title: Prefer Removing a Wrapper Over Adding 5 Utility Classes to It
impact: CRITICAL
impactDescription: reduces DOM depth, visual surfaces, and class count by eliminating unnecessary wrapper elements and decorative containers
tags: intent, simplify, remove-wrappers, flat-markup, less-is-more, subtraction
---

When a component looks wrong, the reflex is to add classes: rounded corners, shadows, borders, background colors. But often the real fix is structural — remove a wrapper div, merge two elements into one, collapse nested containers, or drop the card treatment entirely. Every wrapper you remove eliminates class noise and usually improves clarity.

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

**Correct (flatten structure and remove unnecessary card surface):**
```html
<div class="space-y-1">
  <h3 class="text-base font-semibold text-gray-900">New Message</h3>
  <p class="mt-1 text-sm text-gray-500">From support team</p>
  <p class="pt-2 text-sm leading-relaxed text-gray-600">Your request has been received.</p>
</div>
```

Count both DOM depth and visual surfaces. If a component is 4+ levels deep, or if it stacks border + shadow + background without clear purpose, remove structure until each remaining layer communicates something specific.

**Simplicity gate:** Before adding any new border, shadow, ring, or container, confirm what user problem it solves. If the answer is only "looks nicer," prefer spacing/typography adjustments first.

**Important:** The key insight is removing wrapper divs and decorative borders — not content elements. If an icon, image, or label serves as a visual anchor for scanning (e.g., notification icons in a list, user avatars in a feed), keep it. Only remove elements that exist purely for visual decoration or structural nesting without semantic purpose.

**Taste checkpoint:** After simplifying, does the component still communicate its purpose at a glance? A notification icon, user avatar, or status indicator may look decorative but serves as a visual anchor for scanning. Remove structural wrappers, not functional signifiers. If you can't tell what a component does without reading the text, you may have over-simplified.

Reference: Refactoring UI — "Start with a Feature, Not a Layout"
