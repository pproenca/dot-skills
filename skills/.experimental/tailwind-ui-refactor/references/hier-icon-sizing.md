---
title: Size Icons Relative to Adjacent Text, Not to Fill Space
impact: MEDIUM-HIGH
impactDescription: prevents icons from dominating the visual hierarchy
tags: hier, icons, sizing, balance, alignment
---

Icons next to text should feel balanced with the text, not compete with it. An icon that's too large pulls attention from the content. When icons are decorative, keep them smaller. When icons ARE the primary content (e.g., feature grid), they can be larger.

**Incorrect (icon dominates the text):**
```html
<div class="flex items-center gap-2">
  <svg class="h-8 w-8 text-blue-600"><!-- icon --></svg>
  <span class="text-sm text-gray-700">Download Report</span>
</div>
```

**Correct (icon balances with text):**
```html
<div class="flex items-center gap-1.5">
  <svg class="h-4 w-4 text-gray-400"><!-- icon --></svg>
  <span class="text-sm text-gray-700">Download Report</span>
</div>
```

Reference: Refactoring UI — "Visual Hierarchy"
