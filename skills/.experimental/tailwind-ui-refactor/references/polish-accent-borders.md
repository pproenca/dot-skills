---
title: Add Accent Borders to Highlight Important Elements
impact: LOW
impactDescription: adds visual distinction to cards, alerts, and active states
tags: polish, borders, accent, color, highlight
---

A small colored border on one side of a card, alert, or active navigation item adds distinction without overwhelming. Use the left border for side-accent, top border for cards, and bottom border for active tabs.

**Incorrect (no visual emphasis on important card):**
```html
<div class="rounded-lg border p-4">
  <h3 class="font-semibold">Important Notice</h3>
  <p class="mt-1 text-sm text-gray-600">Your account needs verification.</p>
</div>
```

**Correct (accent border draws the eye):**
```html
<div class="rounded-lg border-l-4 border-l-blue-500 bg-blue-50 p-4">
  <h3 class="font-semibold text-gray-900">Important Notice</h3>
  <p class="mt-1 text-sm text-gray-700">Your account needs verification.</p>
</div>
```

Reference: Refactoring UI — "Finishing Touches"
