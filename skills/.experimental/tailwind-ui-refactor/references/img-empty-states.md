---
title: Design Meaningful Empty States With Clear CTAs
impact: LOW-MEDIUM
impactDescription: prevents dead-end "No data" screens by adding icon, descriptive copy, and primary CTA
tags: img, empty-states, onboarding, cta, illustration
---

Empty states are the first thing new users see. A blank screen with "No data" is a missed opportunity. Add an illustration, explain what goes here, and provide a clear action to get started.

**Incorrect (bare empty state):**
```html
<div class="p-8 text-center">
  <p class="text-gray-500">No projects found.</p>
</div>
```

**Correct (welcoming empty state with CTA):**
```html
<div class="flex flex-col items-center px-6 py-16 text-center">
  <div class="flex h-16 w-16 items-center justify-center rounded-full bg-blue-50">
    <svg class="h-8 w-8 text-blue-500"><!-- folder/project icon --></svg>
  </div>
  <h3 class="mt-4 text-base font-semibold text-gray-900">No projects yet</h3>
  <p class="mt-1 max-w-sm text-sm text-gray-500">Get started by creating your first project. You can organize your work and collaborate with your team.</p>
  <button class="mt-6 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">Create Project</button>
</div>
```

Reference: Refactoring UI — "Finishing Touches"
