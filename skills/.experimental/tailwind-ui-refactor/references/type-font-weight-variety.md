---
title: Choose Fonts With at Least 5 Weight Variations
impact: HIGH
impactDescription: enables proper hierarchy without relying on size alone
tags: type, font-selection, font-weight, google-fonts
---

Fonts with limited weight options (just regular and bold) force you to rely on size changes for hierarchy. Choose typefaces with at least 5 weights (300, 400, 500, 600, 700) so you can create subtle hierarchy with weight alone.

**Incorrect (limited weights, relying on size for hierarchy):**
```html
<!-- Using a font with only regular (400) and bold (700) -->
<div class="space-y-2 font-sans">
  <h3 class="text-2xl font-bold">Project Name</h3>
  <p class="text-base font-normal">Team Lead</p>
  <p class="text-sm font-normal text-gray-500">Last updated 2 hours ago</p>
</div>
```

**Correct (rich weight range for nuanced hierarchy):**
```html
<!-- Using a font with weights 300-800 (e.g., Inter) -->
<div class="space-y-1 font-sans">
  <h3 class="text-lg font-semibold text-gray-900">Project Name</h3>
  <p class="text-sm font-medium text-gray-600">Team Lead</p>
  <p class="text-sm text-gray-400">Last updated 2 hours ago</p>
</div>
```

Reference: Refactoring UI — "Designing Text"
