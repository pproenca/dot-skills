---
title: De-emphasize Secondary Content Instead of Emphasizing Primary
impact: CRITICAL
impactDescription: reduces visual noise across entire interface
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
  <span class="text-xs font-medium uppercase tracking-wide text-gray-400">Status</span>
  <p class="text-lg font-semibold text-gray-900">Active</p>
  <span class="text-xs font-medium uppercase tracking-wide text-gray-400">Since</span>
  <p class="text-lg font-semibold text-gray-900">January 2024</p>
</div>
```

Reference: Refactoring UI — "Visual Hierarchy"
