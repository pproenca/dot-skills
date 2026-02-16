---
title: Stop When Nothing More Can Be Removed — Not When Everything Has Been Added
impact: HIGH
impactDescription: prevents over-engineering by defining a clear completion signal based on subtraction
tags: taste, simplicity, done, restraint, subtraction
---

A component is done when every element earns its place and removing any one of them would hurt the user's ability to accomplish their task. More CSS is not more design. More elements are not more polish. The goal is not to use every technique in this skill — it's to use the fewest techniques that make the UI clear, usable, and emotionally appropriate.

**Incorrect (over-designed — every polish technique applied):**
```html
<div class="rounded-xl border border-gray-200 bg-gradient-to-b from-white to-gray-50 p-6 shadow-md ring-1 ring-gray-100">
  <div class="flex items-center gap-3">
    <div class="flex h-10 w-10 items-center justify-center rounded-full bg-blue-100">
      <svg class="h-5 w-5 text-blue-600"><!-- bell icon --></svg>
    </div>
    <div>
      <h3 class="text-base font-bold text-gray-900">New Comment</h3>
      <p class="text-xs text-gray-500">2 minutes ago</p>
    </div>
  </div>
  <p class="mt-3 text-sm leading-relaxed text-gray-600">Alex left a comment on your design review for the homepage redesign project.</p>
  <div class="mt-4 flex gap-2">
    <button class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white shadow-sm transition-all hover:bg-blue-700 hover:shadow">View</button>
    <button class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 transition-colors hover:bg-gray-50">Dismiss</button>
  </div>
</div>
```

**Correct (done — nothing more to remove):**
```html
<div class="rounded-lg border border-gray-200 bg-white p-4">
  <p class="text-sm text-gray-900"><strong>Alex</strong> commented on <strong>Homepage Redesign</strong></p>
  <p class="mt-1 text-xs text-gray-500">2 minutes ago</p>
  <div class="mt-3 flex gap-3">
    <button class="text-sm font-medium text-blue-600">View</button>
    <button class="text-sm text-gray-500">Dismiss</button>
  </div>
</div>
```

The over-designed version has: gradient background, ring + border (redundant), icon circle (decorative), bold heading (unnecessary for a notification), shadow on hover (over-engineered for a notification card), two visually heavy buttons for a low-stakes action.

The done version removes everything that doesn't serve the user: the notification content is a single natural sentence, the timestamp is minimal, and the actions are text-only because neither is high-stakes. Every element earns its place.

**Completion checklist:** (1) Can I remove any element without hurting the user's task? (2) Can I merge two elements into one? (3) Can I replace a styled element with plain text? If any answer is yes, the component is not done.

Reference: Ken Kocienda, Creative Selection — Apple's iterative process stripped away complexity until only the essential remained
