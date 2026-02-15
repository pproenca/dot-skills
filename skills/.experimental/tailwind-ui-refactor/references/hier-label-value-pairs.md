---
title: Combine Labels and Values Into Natural Language
impact: MEDIUM
impactDescription: reduces label-value markup by 2× per data point by combining into natural phrases like "3 bedrooms"
tags: hier, labels, data-display, readability
---

Instead of treating labels and values as separate visual elements with label-colon-value patterns, combine them into natural phrases. This reduces visual noise and is easier to scan.

**When NOT to use this pattern:** Keep traditional label-value pairs in admin dashboards, settings pages, data tables, and any UI where users scan labels to locate specific fields. Before converting, check whether the label text appears elsewhere in the component or parent context — if a section heading already says "Property Details," converting to natural language is fine, but if the label is the only way users know what the number means, keep it. When you do keep labels, style them per [`hier-deemphasize-secondary`](hier-deemphasize-secondary.md). The natural-language pattern works best for marketing content, property cards, and profile summaries — not data-dense interfaces.

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
