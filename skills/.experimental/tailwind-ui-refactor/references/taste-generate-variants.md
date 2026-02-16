---
title: Generate 2-3 Visual Variants Before Committing to One
impact: CRITICAL
impactDescription: prevents generic "first attempt" UI by forcing comparison between deliberate alternatives
tags: taste, variants, iteration, creative-selection, demo
---

One correct answer is a formula. Two correct answers is a choice. Three correct answers is taste. After applying mechanical rules, create 2-3 variants of the component with deliberate tradeoffs — not random variations, but intentional explorations of different design directions. Then select the one that best serves the user's task and emotional state.

**Incorrect (committing to the first approach without exploring alternatives):**
```html
<!-- Only one layout considered — no comparison, no selection -->
<div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
  <div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
    <h3 class="text-base font-semibold text-gray-900">Flight to Paris</h3>
    <p class="mt-1 text-sm text-gray-600">CDG · Mar 15 · 7h 20m</p>
    <p class="mt-4 text-2xl font-bold text-gray-900">$487</p>
    <button class="mt-4 w-full rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">Select</button>
  </div>
</div>
```

**Correct (generating 2-3 variants with deliberate tradeoffs, then selecting):**

Variant A (spacious, card-based — optimized for browsing):
```html
<div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
  <div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
    <h3 class="text-base font-semibold text-gray-900">Flight to Paris</h3>
    <p class="mt-1 text-sm text-gray-600">CDG · Mar 15 · 7h 20m</p>
    <p class="mt-4 text-2xl font-bold text-gray-900">$487</p>
    <button class="mt-4 w-full rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">Select</button>
  </div>
</div>
```

**Variant B (dense, table-like — optimized for comparison):**
```html
<div class="divide-y divide-gray-200">
  <div class="flex items-center justify-between px-4 py-3">
    <div>
      <p class="text-sm font-medium text-gray-900">Flight to Paris</p>
      <p class="text-xs text-gray-500">CDG · Mar 15 · 7h 20m</p>
    </div>
    <div class="flex items-center gap-4">
      <p class="text-lg font-bold text-gray-900">$487</p>
      <button class="rounded-lg bg-blue-600 px-3 py-1.5 text-sm font-medium text-white">Select</button>
    </div>
  </div>
</div>
```

**Variant C (minimal, focused — optimized for quick decision):**
```html
<div class="space-y-2">
  <button class="flex w-full items-center justify-between rounded-lg border border-gray-200 px-4 py-3 text-left transition-colors hover:border-blue-300 hover:bg-blue-50">
    <span class="text-sm font-medium text-gray-900">Paris CDG · Mar 15 · 7h 20m</span>
    <span class="text-lg font-bold text-gray-900">$487</span>
  </button>
</div>
```

Each variant makes different tradeoffs: A gives each option visual weight for leisurely browsing, B enables rapid price comparison across many options, C reduces the action to a single tap. The right choice depends on the user's context — are they exploring or deciding?

**How to select:** Ask three questions: (1) What is the user's primary task at this moment? (2) How many items will they compare? (3) Are they browsing or ready to commit? The answer selects the variant, not personal preference.

Reference: Ken Kocienda, Creative Selection — "Creative selection is the process of generating and evaluating many alternatives to find the best one"
