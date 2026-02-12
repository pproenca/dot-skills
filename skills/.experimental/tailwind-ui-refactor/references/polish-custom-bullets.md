---
title: Replace Default Bullets With Icons or Checkmarks
impact: LOW
impactDescription: replaces default list-disc with icon bullets using flex + svg for 2-3x visual engagement
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
<ul class="space-y-3 text-sm text-gray-600">
  <li class="flex items-start gap-2">
    <svg class="mt-0.5 h-4 w-4 shrink-0 text-green-500" fill="currentColor" viewBox="0 0 20 20"><!-- checkmark icon --></svg>
    <span>Unlimited projects</span>
  </li>
  <li class="flex items-start gap-2">
    <svg class="mt-0.5 h-4 w-4 shrink-0 text-green-500" fill="currentColor" viewBox="0 0 20 20"><!-- checkmark icon --></svg>
    <span>Priority support</span>
  </li>
  <!-- repeat pattern for remaining items -->
</ul>
```

Reference: Refactoring UI — "Finishing Touches"
