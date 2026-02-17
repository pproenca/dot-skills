---
title: Match Border Radius to Brand Personality
impact: LOW
impactDescription: eliminates mixed border-radius values (rounded vs rounded-lg vs rounded-full) across components
tags: polish, border-radius, personality, branding, consistency
---

Border radius communicates personality. No radius = serious/formal. Small radius = professional/neutral. Large radius = playful/friendly. Pick one approach and apply it consistently to all elements: buttons, cards, inputs, avatars.

**Incorrect (inconsistent border radius):**
```html
<div class="space-y-4">
  <button class="rounded-full bg-blue-600 px-4 py-2 text-white">Submit</button>
  <div class="rounded border p-4">Card content</div>
  <input class="rounded-lg border px-3 py-2" />
  <span class="rounded-none bg-green-100 px-2 py-1 text-green-700">Badge</span>
</div>
```

**Correct (consistent radius throughout):**
```html
<div class="space-y-4">
  <button class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">Submit</button>
  <div class="rounded-lg border p-4">Card content</div>
  <input class="rounded-lg border px-3 py-2" />
  <span class="rounded-lg bg-green-100 px-2 py-1 text-xs font-medium text-green-700">Badge</span>
</div>
```

Reference: Refactoring UI — "Starting from Scratch"
