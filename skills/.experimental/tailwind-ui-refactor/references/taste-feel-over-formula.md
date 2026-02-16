---
title: Trust Your Felt Sense — If Something Feels Off, Investigate
impact: HIGH
impactDescription: prevents 1-3× rework per component by catching gestalt issues that pass mechanical rules
tags: taste, intuition, gestalt, feel, refinement
---

After applying mechanical rules, step back and look at the whole component. If something feels off — even if every rule is satisfied — investigate. Your instinct is detecting a problem the rules can't articulate: mismatched rhythm, conflicting visual weights, or a gestalt that doesn't cohere. Never ship a component that follows all rules but feels wrong.

**Incorrect (all rules satisfied, but something feels off):**
```html
<div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
  <div class="flex items-center justify-between">
    <h3 class="text-lg font-semibold text-gray-900">Monthly Report</h3>
    <span class="rounded-full bg-green-100 px-2 py-1 text-xs font-medium text-green-700">Published</span>
  </div>
  <p class="mt-2 text-sm text-gray-600">Q4 performance analysis covering revenue, churn, and expansion metrics.</p>
  <div class="mt-4 flex items-center gap-4 text-sm text-gray-500">
    <span>Jan 15, 2026</span>
    <span>12 pages</span>
    <span>4 contributors</span>
  </div>
  <div class="mt-4 flex gap-2">
    <button class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">View Report</button>
    <button class="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700">Download</button>
    <button class="px-4 py-2 text-sm text-gray-500">Share</button>
  </div>
</div>
```

**Correct (same component, refined by feel):**
```html
<div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
  <div class="flex items-center justify-between">
    <div>
      <h3 class="text-base font-semibold text-gray-900">Monthly Report</h3>
      <p class="mt-1 text-sm text-gray-600">Q4 performance — revenue, churn, expansion</p>
    </div>
    <span class="rounded-full bg-green-100 px-2 py-1 text-xs font-medium text-green-700">Published</span>
  </div>
  <p class="mt-4 text-xs text-gray-500">Jan 15, 2026 · 12 pages · 4 contributors</p>
  <div class="mt-5 flex gap-3">
    <button class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white">View Report</button>
    <button class="px-4 py-2 text-sm font-medium text-gray-600">Download</button>
  </div>
</div>
```

**What changed and why:** The title was too large for a card (text-lg → text-base). The description was redundant with the title — shortened. The metadata was visually heavy as three separate spans — collapsed into one line with interpuncts. Three buttons became two — "Share" rarely needs to be visible (progressive disclosure). The "Download" button lost its border — two button styles is enough, three creates visual noise. Each change came from feeling "too much" and investigating what could be removed.

**The refinement loop:** Look → Feel → Identify → Adjust → Repeat. Stop when nothing feels off and nothing can be removed.

Reference: Ken Kocienda, Creative Selection — "Taste is a refined sense of judgment, finding the balance that produces a pleasing and integrated whole"
