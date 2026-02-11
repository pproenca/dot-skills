---
title: Combine Labels and Values Into Natural Language
impact: HIGH
impactDescription: makes data-dense displays more scannable by combining label-value pairs
tags: hier, labels, data-display, readability
---

Instead of treating labels and values as separate visual elements with label-colon-value patterns, combine them into natural phrases. This reduces visual noise and is easier to scan.

**Incorrect (rigid label-value pairs):**
```html
<div class="grid grid-cols-2 gap-2">
  <span class="text-sm font-semibold text-gray-700">Bedrooms:</span>
  <span class="text-sm text-gray-900">3</span>
  <span class="text-sm font-semibold text-gray-700">Bathrooms:</span>
  <span class="text-sm text-gray-900">2</span>
  <span class="text-sm font-semibold text-gray-700">Area:</span>
  <span class="text-sm text-gray-900">1,200 sq ft</span>
</div>
```

**Correct (natural language, scannable):**
```html
<div class="flex gap-4 text-sm text-gray-600">
  <span><strong class="font-semibold text-gray-900">3</strong> bedrooms</span>
  <span><strong class="font-semibold text-gray-900">2</strong> bathrooms</span>
  <span><strong class="font-semibold text-gray-900">1,200</strong> sq ft</span>
</div>
```

Reference: Refactoring UI — "Visual Hierarchy"
