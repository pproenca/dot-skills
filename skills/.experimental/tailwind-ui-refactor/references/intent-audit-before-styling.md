---
title: Audit What Each Element Communicates Before Changing Any CSS
impact: CRITICAL
impactDescription: prevents 30-50% of unnecessary markup by identifying purposeless elements first
tags: intent, audit, purpose, user-goal, information-hierarchy
---

Before adding or changing any Tailwind classes, read the component and answer: What is the user trying to accomplish on this screen? What is the most important piece of data? Does every element contribute to that goal? Styling purposeless elements wastes effort and adds noise.

**Incorrect (styling everything without questioning purpose):**
```html
<div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
  <div class="flex items-center justify-between">
    <h3 class="text-lg font-semibold text-gray-900">Order #4521</h3>
    <span class="rounded-full bg-green-100 px-2 py-1 text-xs font-medium text-green-700">Completed</span>
  </div>
  <p class="mt-2 text-sm text-gray-500">Placed on March 12, 2025</p>
  <p class="mt-1 text-sm text-gray-500">Customer since 2019</p>
  <p class="mt-1 text-sm text-gray-500">Payment method: Visa ending 4242</p>
  <p class="mt-1 text-sm text-gray-500">Shipping: Standard delivery</p>
  <p class="mt-1 text-sm text-gray-500">IP address: 192.168.1.1</p>
  <p class="mt-3 text-base font-semibold text-gray-900">Total: $127.50</p>
</div>
```

**Correct (audit first — keep only what serves the user's task):**
```html
<!-- User task: quickly review order status and amount -->
<div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
  <div class="flex items-center justify-between">
    <h3 class="text-lg font-semibold text-gray-900">Order #4521</h3>
    <span class="rounded-full bg-green-100 px-2 py-1 text-xs font-medium text-green-700">Completed</span>
  </div>
  <p class="mt-2 text-sm text-gray-500">March 12, 2025</p>
  <p class="mt-3 text-base font-semibold text-gray-900">$127.50</p>
</div>
```

Ask before refactoring: (1) What is the user's primary task? (2) Which data is essential for that task? (3) Can anything be removed entirely? Only then style what remains.

Reference: Refactoring UI — "Start with a Feature, Not a Layout"
