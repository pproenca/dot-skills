---
title: Use Size, Weight, and Color for Hierarchy — Not Just Size
impact: CRITICAL
impactDescription: transforms flat layouts into scannable interfaces
tags: hier, hierarchy, size, weight, color, contrast
---

When everything is the same size and weight, nothing stands out. Use three levers — size, weight, and color — to create clear visual hierarchy. Primary content gets dark color + larger size. Secondary content gets smaller size + medium gray. Tertiary content gets smallest size + light gray.

**Incorrect (everything competes for attention):**
```html
<div class="p-6">
  <h3 class="text-lg font-bold text-black">John Smith</h3>
  <p class="text-lg font-bold text-black">Software Engineer</p>
  <p class="text-lg font-bold text-black">john@example.com</p>
</div>
```

**Correct (clear three-level hierarchy):**
```html
<div class="p-6">
  <h3 class="text-lg font-semibold text-gray-900">John Smith</h3>
  <p class="text-sm font-medium text-gray-500">Software Engineer</p>
  <p class="text-sm text-gray-400">john@example.com</p>
</div>
```

Reference: Refactoring UI — "Hierarchy is Everything"
