---
title: Replace Default Bullets With Icons or Checkmarks
impact: LOW
impactDescription: adds visual polish to feature lists and marketing pages
tags: polish, lists, bullets, icons, checkmarks
---

Default bullet points are generic and boring. Replace them with relevant icons — checkmarks for feature lists, colored dots for status lists, or custom SVGs for themed content.

**Incorrect (default bullets):**
```html
<ul class="list-disc space-y-2 pl-5 text-sm text-gray-600">
  <li>Unlimited projects</li>
  <li>Priority support</li>
  <li>Custom integrations</li>
  <li>Team collaboration</li>
</ul>
```

**Correct (custom checkmark icons):**
```html
<ul class="space-y-3 text-sm">
  <li class="flex items-start gap-2">
    <svg class="mt-0.5 h-4 w-4 shrink-0 text-green-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" /></svg>
    <span class="text-gray-700">Unlimited projects</span>
  </li>
  <li class="flex items-start gap-2">
    <svg class="mt-0.5 h-4 w-4 shrink-0 text-green-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" /></svg>
    <span class="text-gray-700">Priority support</span>
  </li>
  <li class="flex items-start gap-2">
    <svg class="mt-0.5 h-4 w-4 shrink-0 text-green-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" /></svg>
    <span class="text-gray-700">Custom integrations</span>
  </li>
  <li class="flex items-start gap-2">
    <svg class="mt-0.5 h-4 w-4 shrink-0 text-green-500" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" /></svg>
    <span class="text-gray-700">Team collaboration</span>
  </li>
</ul>
```

Reference: Refactoring UI — "Finishing Touches"
