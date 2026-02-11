---
title: Use Background Color Differences to Separate Sections
impact: MEDIUM
impactDescription: creates clear visual boundaries without adding border lines
tags: sep, background, sections, containers, alternating
---

Instead of using a border between adjacent sections, give them different background colors. The contrast between backgrounds creates a natural boundary that feels lighter than a border.

**Incorrect (border-separated sections):**
```html
<div class="border-b bg-white p-6">
  <h2 class="text-xl font-bold">Profile</h2>
  <p class="text-gray-600">Manage your account details</p>
</div>
<div class="border-b bg-white p-6">
  <h2 class="text-xl font-bold">Notifications</h2>
  <p class="text-gray-600">Configure alert preferences</p>
</div>
```

**Correct (alternating backgrounds separate sections):**
```html
<div class="bg-white p-6">
  <h2 class="text-xl font-bold text-gray-900">Profile</h2>
  <p class="text-gray-600">Manage your account details</p>
</div>
<div class="bg-gray-50 p-6">
  <h2 class="text-xl font-bold text-gray-900">Notifications</h2>
  <p class="text-gray-600">Configure alert preferences</p>
</div>
```

Reference: Refactoring UI — "Finishing Touches"
