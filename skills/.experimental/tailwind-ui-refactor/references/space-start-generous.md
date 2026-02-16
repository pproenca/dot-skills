---
title: Start With Too Much Whitespace, Then Remove
impact: CRITICAL
impactDescription: prevents the #1 amateur tell — cramped spacing that signals the UI was not designed with care
tags: space, whitespace, padding, margin, layout, craft
---

Cramped interfaces feel overwhelming and cheap. Generous interfaces feel considered and premium. This is not subjective — it's the most reliable signal users have for "someone cared about this." Start with more whitespace than you think you need, then remove it until it feels right. It's easier to remove space than to add it later.

**Incorrect (cramped, insufficient spacing):**
```html
<div class="rounded border p-2">
  <h3 class="text-lg font-bold">Project Alpha</h3>
  <p class="text-sm text-gray-600">Due: March 15</p>
  <p class="text-sm text-gray-600">A new marketing campaign for Q2 launch targeting enterprise customers.</p>
  <button class="mt-1 rounded bg-blue-600 px-3 py-1 text-sm text-white">View Details</button>
</div>
```

**Correct (generous spacing feels considered):**
```html
<div class="rounded-lg border p-6">
  <h3 class="text-lg font-bold">Project Alpha</h3>
  <p class="mt-1 text-sm text-gray-600">Due: March 15</p>
  <p class="mt-3 text-sm text-gray-600">A new marketing campaign for Q2 launch targeting enterprise customers.</p>
  <button class="mt-5 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">View Details</button>
</div>
```

**When NOT to use generous spacing:** Admin interfaces, data tables, and dense dashboards where a confident power user needs to scan quickly. In these contexts, tight spacing (py-2, px-3) signals respect for the user's efficiency. See [`intent-match-context-fidelity`](intent-match-context-fidelity.md) for the context decision matrix.

**Taste checkpoint:** After adding generous spacing, ask: "Does this feel premium, or does it feel empty? Premium spacing has purpose — it groups related elements and separates unrelated ones. Empty spacing is uniform padding that wastes screen real estate without creating visual relationships."

Reference: Refactoring UI — "Layout and Spacing"
