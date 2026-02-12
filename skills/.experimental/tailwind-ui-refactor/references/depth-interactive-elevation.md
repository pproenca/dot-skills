---
title: Use Shadow Changes to Communicate Interactivity
impact: MEDIUM
impactDescription: enables hover/active elevation feedback with shadow-sm, hover:shadow-md, and active:shadow-sm transitions
tags: depth, shadows, hover, interaction, feedback, transition
---

Increasing shadow on hover makes elements feel like they're rising toward the user, communicating "this is clickable." Decreasing shadow on press makes them feel pushed down. Use transitions for smooth elevation changes.

**Incorrect (no elevation feedback):**
```html
<div class="cursor-pointer rounded-lg border p-4">
  <h3 class="font-semibold">Clickable Card</h3>
  <p class="text-sm text-gray-600">Click to view details</p>
</div>
```

**Correct (elevation changes on interaction):**
```html
<div class="cursor-pointer rounded-lg border p-4 shadow-sm transition-shadow duration-150 hover:shadow-md active:shadow-sm">
  <h3 class="font-semibold">Clickable Card</h3>
  <p class="text-sm text-gray-600">Click to view details</p>
</div>
```

Reference: Refactoring UI — "Depth"
