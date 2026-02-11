---
title: Use Spacing to Show Relationships Between Elements
impact: CRITICAL
impactDescription: makes group membership instantly clear without visual borders
tags: space, proximity, grouping, gestalt, relationships
---

Elements that are related should be closer together than elements that aren't. When spacing is uniform everywhere, users can't tell which elements belong together. Increase spacing between groups and decrease spacing within groups.

**Incorrect (uniform spacing hides relationships):**
```html
<div class="space-y-4">
  <label class="text-sm font-medium text-gray-700">Full Name</label>
  <input class="rounded border px-3 py-2" type="text" />
  <label class="text-sm font-medium text-gray-700">Email Address</label>
  <input class="rounded border px-3 py-2" type="email" />
  <label class="text-sm font-medium text-gray-700">Password</label>
  <input class="rounded border px-3 py-2" type="password" />
</div>
```

**Correct (tight within groups, loose between):**
```html
<div class="space-y-6">
  <div>
    <label class="text-sm font-medium text-gray-700">Full Name</label>
    <input class="mt-1.5 w-full rounded-lg border px-3 py-2" type="text" />
  </div>
  <div>
    <label class="text-sm font-medium text-gray-700">Email Address</label>
    <input class="mt-1.5 w-full rounded-lg border px-3 py-2" type="email" />
  </div>
  <div>
    <label class="text-sm font-medium text-gray-700">Password</label>
    <input class="mt-1.5 w-full rounded-lg border px-3 py-2" type="password" />
  </div>
</div>
```

Reference: Refactoring UI — "Layout and Spacing"
