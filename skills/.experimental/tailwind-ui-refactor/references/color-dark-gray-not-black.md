---
title: Use Dark Gray Instead of Pure Black for Text
impact: MEDIUM-HIGH
impactDescription: reduces harshness while maintaining readability
tags: color, black, gray, text-color, softness
---

Pure black (#000) text on white creates maximum contrast that feels harsh and aggressive. Most well-designed interfaces use dark gray (gray-800 or gray-900) for primary text, which is easier on the eyes while maintaining excellent readability.

**Incorrect (pure black text):**
```html
<div class="p-6">
  <h2 class="text-2xl font-bold text-black">Account Overview</h2>
  <p class="mt-2 text-black">Welcome back to your dashboard. Here's a summary of your recent activity.</p>
</div>
```

**Correct (dark gray, softer feel):**
```html
<div class="p-6">
  <h2 class="text-2xl font-bold text-gray-900">Account Overview</h2>
  <p class="mt-2 text-gray-700">Welcome back to your dashboard. Here's a summary of your recent activity.</p>
</div>
```

Reference: Refactoring UI — "Working with Color"
