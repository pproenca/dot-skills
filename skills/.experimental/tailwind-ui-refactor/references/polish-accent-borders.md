---
title: Use Accent Borders Sparingly for One Focal Element
impact: LOW
impactDescription: adds optional emphasis to a single high-priority element after simpler hierarchy cues are exhausted
tags: polish, borders, accent, color, highlight, restraint
---

Accent borders are optional, not default. First try hierarchy with type weight, color, and spacing. Add an accent border only when one specific element still needs stronger emphasis.

**Incorrect (accent borders everywhere create visual noise):**
```html
<div class="space-y-3">
  <div class="rounded-lg border-l-4 border-l-blue-500 bg-blue-50 p-4">Billing update</div>
  <div class="rounded-lg border-l-4 border-l-green-500 bg-green-50 p-4">Team update</div>
  <div class="rounded-lg border-l-4 border-l-purple-500 bg-purple-50 p-4">Security update</div>
</div>
```

**Correct (single focal accent, everything else stays neutral):**
```html
<div class="space-y-3">
  <div class="rounded-lg border-l-4 border-l-amber-500 bg-amber-50 p-4">
    <h3 class="font-semibold text-amber-900">Action Required</h3>
    <p class="mt-1 text-sm text-amber-800">Verify your account before checkout.</p>
  </div>
  <div class="rounded-lg bg-white p-4">
    <h3 class="font-medium text-gray-900">Billing update</h3>
    <p class="mt-1 text-sm text-gray-600">Next invoice: March 1</p>
  </div>
</div>
```

**Simplicity rule:** Never combine "card + heavy border + accent border + strong shadow" unless each layer has a distinct purpose.

Reference: Refactoring UI — "Finishing Touches"
