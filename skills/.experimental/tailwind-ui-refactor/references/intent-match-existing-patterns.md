---
title: Audit Existing UI Patterns Before Introducing New Ones
impact: HIGH
impactDescription: prevents visual inconsistency by matching sibling component patterns before restyling
tags: intent, consistency, patterns, audit, system
---

Before restyling a component, check how sibling components in the same UI are already styled. Matching existing spacing, border radius, color usage, and typography hierarchy matters more than optimizing any single component. Consistency across components creates a cohesive interface; individually "improved" components that don't match their siblings create visual chaos.

**Incorrect (each card styled independently — inconsistent patterns):**
```html
<div class="space-y-4">
  <!-- Card 1: rounded-lg, shadow, p-6 -->
  <div class="rounded-lg bg-white p-6 shadow">
    <h3 class="text-lg font-bold text-gray-900">Revenue</h3>
    <p class="mt-2 text-3xl font-semibold text-blue-600">$12,450</p>
  </div>
  <!-- Card 2: rounded-xl, ring, p-4 -->
  <div class="rounded-xl bg-white p-4 ring-1 ring-gray-200">
    <h3 class="text-base font-medium text-gray-700">Orders</h3>
    <p class="mt-1 text-2xl font-bold text-gray-900">342</p>
  </div>
  <!-- Card 3: rounded, border, p-5 -->
  <div class="rounded border border-gray-300 bg-white p-5">
    <h3 class="text-sm font-semibold uppercase tracking-wide text-gray-500">Conversion</h3>
    <p class="mt-3 text-xl text-green-600">4.2%</p>
  </div>
</div>
```

**Correct (consistent patterns across all sibling components):**
```html
<div class="grid grid-cols-3 gap-4">
  <div class="rounded-lg bg-white p-6 shadow-sm">
    <h3 class="text-sm font-medium text-gray-500">Revenue</h3>
    <p class="mt-2 text-2xl font-semibold text-gray-900">$12,450</p>
  </div>
  <div class="rounded-lg bg-white p-6 shadow-sm">
    <h3 class="text-sm font-medium text-gray-500">Orders</h3>
    <p class="mt-2 text-2xl font-semibold text-gray-900">342</p>
  </div>
  <div class="rounded-lg bg-white p-6 shadow-sm">
    <h3 class="text-sm font-medium text-gray-500">Conversion</h3>
    <p class="mt-2 text-2xl font-semibold text-gray-900">4.2%</p>
  </div>
</div>
```

Before refactoring, ask: (1) What border radius do sibling components use? (2) What spacing scale is established? (3) What heading sizes and weights are set? (4) What separator style (border, shadow, background) is the norm? Match those patterns first, then improve the whole set together if needed.

**When NOT to match existing patterns:** When the existing patterns are themselves inconsistent or poorly designed. Matching bad patterns amplifies the problem. If the sibling components are a mess, fix the whole set together rather than matching the mess. See [`system-brand-voice-consistency`](system-brand-voice-consistency.md) for establishing system-level consistency.

**Taste checkpoint:** After matching sibling patterns, ask: "Am I making the whole set better, or am I conforming to mediocrity?" Consistency is not a goal in itself — it's a means to user trust. Consistent mediocrity is worse than one great component that inspires upgrading the rest.

Reference: Refactoring UI — "Hierarchy is Everything" · John Edson, Design Like Apple — Principle 4: "Design Is Systems Thinking"
