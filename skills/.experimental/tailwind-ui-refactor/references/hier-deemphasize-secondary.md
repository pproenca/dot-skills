---
title: Reduce Secondary Content Emphasis Instead of Adding Primary
impact: CRITICAL
impactDescription: reduces visual noise by de-emphasizing secondary text to gray-500+ while maintaining WCAG AA contrast
tags: hier, hierarchy, de-emphasis, contrast, labels
---

When a UI element feels too subtle, the instinct is to make it bigger or bolder. Instead, de-emphasize the competing elements around it. Reducing noise is more effective than adding emphasis.

**Incorrect (over-emphasized — everything bold and dark):**
```html
<div class="rounded-lg border p-4">
  <span class="text-sm font-bold text-gray-900">Status</span>
  <p class="text-lg font-bold text-gray-900">Active</p>
  <span class="text-sm font-bold text-gray-900">Since</span>
  <p class="text-lg font-bold text-gray-900">January 2024</p>
</div>
```

**Correct (de-emphasized labels, values stand out naturally):**
```html
<div class="rounded-lg border p-4">
  <span class="text-xs font-medium uppercase tracking-wide text-gray-500">Status</span>
  <p class="text-lg font-semibold text-gray-900">Active</p>
  <span class="text-xs font-medium uppercase tracking-wide text-gray-500">Since</span>
  <p class="text-lg font-semibold text-gray-900">January 2024</p>
</div>
```

When labels add no information (e.g., "3 bedrooms" is self-explanatory), see [`hier-label-value-pairs`](hier-label-value-pairs.md) for removing them entirely. Use this de-emphasis pattern when labels are needed for disambiguation (e.g., "Status: Active" in a detail view).

**Taste checkpoint:** After de-emphasizing, check the squint test: with the screen slightly unfocused, can you still read the de-emphasized text? If it vanishes, you've gone too far — you've hidden information, not de-emphasized it. De-emphasis means "read this second," not "struggle to read this."

Reference: Refactoring UI — "Visual Hierarchy"
