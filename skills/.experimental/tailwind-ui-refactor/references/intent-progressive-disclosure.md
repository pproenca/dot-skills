---
title: Hide Secondary Information Behind Interactions
impact: CRITICAL
impactDescription: reduces visible content per screen by hiding secondary information behind interactions
tags: intent, progressive-disclosure, collapse, expand, detail, simplify
---

Showing everything at once overwhelms users. Progressive disclosure shows only what is needed for the current decision, and reveals more on demand. Before styling a dense component, identify what is primary (always visible) vs. secondary (shown on click/hover/expand).

**Incorrect (all metadata visible at once):**
```html
<div class="space-y-2 rounded-lg border p-6">
  <h3 class="text-lg font-semibold text-gray-900">flight-api-service</h3>
  <p class="text-sm text-gray-500">RESTful API for flight search and booking</p>
  <p class="text-sm text-gray-500">Language: TypeScript</p>
  <p class="text-sm text-gray-500">Framework: Express 4.18</p>
  <p class="text-sm text-gray-500">Last deploy: 2 hours ago</p>
  <p class="text-sm text-gray-500">Uptime: 99.97%</p>
  <p class="text-sm text-gray-500">Avg response: 145ms</p>
  <p class="text-sm text-gray-500">Daily requests: 2.4M</p>
  <p class="text-sm text-gray-500">Error rate: 0.03%</p>
  <p class="text-sm text-gray-500">Owner: Platform Team</p>
</div>
```

**Correct (primary info visible, secondary behind disclosure):**
```html
<div class="rounded-lg border p-6">
  <div class="flex items-center justify-between">
    <h3 class="text-lg font-semibold text-gray-900">flight-api-service</h3>
    <span class="text-sm text-green-600">99.97% uptime</span>
  </div>
  <p class="mt-1 text-sm text-gray-500">Last deployed 2 hours ago · 145ms avg</p>
  <details class="mt-3">
    <summary class="cursor-pointer text-sm font-medium text-blue-600">Show details</summary>
    <div class="mt-2 space-y-1 text-sm text-gray-500">
      <p>TypeScript · Express 4.18</p>
      <p>2.4M daily requests · 0.03% error rate</p>
      <p>Owner: Platform Team</p>
    </div>
  </details>
</div>
```

Decide what the user needs to see first. Everything else goes behind a click.

**When NOT to use progressive disclosure:** When the user needs to compare multiple data points simultaneously (e.g., a comparison table, a multi-field form where fields depend on each other). Hiding fields that the user needs to see together creates frustrating reveal-compare-reveal cycles. Progressive disclosure works for sequential information, not parallel information.

**Taste checkpoint:** After hiding secondary content, try the flow as a first-time user. Is the disclosure mechanism obvious? A `<details>` element or "Show more" link that blends into the background might as well not exist. The user must be able to discover the hidden content without guessing.

Reference: Refactoring UI — "Start with a Feature, Not a Layout"
