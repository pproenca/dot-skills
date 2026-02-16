---
title: Audit What Each Element Communicates Before Changing Any CSS
impact: CRITICAL
impactDescription: prevents unnecessary markup by identifying elements that don't serve the user's task
tags: intent, audit, purpose, user-goal, information-hierarchy
---

Before adding or changing any Tailwind classes, read the component and answer: What is the user trying to accomplish on this screen? How are they feeling while doing it? What is the most important piece of data? Does every element contribute to that goal? Styling purposeless elements wastes effort and adds noise.

**Incorrect (8 fields shown — 5 useful, but only 3 essential for the primary task):**
```html
<div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
  <div class="flex items-center justify-between">
    <h3 class="text-lg font-semibold text-gray-900">Order #4521</h3>
    <span class="rounded-full bg-green-100 px-2 py-1 text-xs font-medium text-green-700">Completed</span>
  </div>
  <p class="mt-2 text-sm text-gray-600">Placed on March 12, 2025</p>
  <p class="mt-1 text-sm text-gray-600">Customer since 2019</p>
  <p class="mt-1 text-sm text-gray-600">Payment: Visa ending 4242</p>
  <p class="mt-1 text-sm text-gray-600">Shipping: Standard delivery</p>
  <p class="mt-1 text-sm text-gray-600">Tracking: UPS 1Z999AA10123456784</p>
  <p class="mt-1 text-sm text-gray-600">Notes: Gift wrap requested</p>
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
  <p class="mt-2 text-sm text-gray-600">March 12, 2025</p>
  <p class="mt-3 text-base font-semibold text-gray-900">$127.50</p>
</div>
```

The incorrect example is not absurd — every field is legitimate data. But the user scanning an order list needs status, date, and amount. Customer tenure, payment method, shipping, and tracking are secondary information that belongs behind a disclosure (`<details>`) or on the order detail page.

Ask before refactoring: (1) What is the user's primary task? (2) How are they feeling? (3) Which data is essential for that task? (4) Can anything be moved behind an interaction? Only then style what remains.

**Taste checkpoint:** After auditing, ask: "If I removed one more element, would the user still be able to accomplish their task? If yes, remove it."

Reference: Refactoring UI — "Start with a Feature, Not a Layout" · Ken Kocienda, Creative Selection — empathy starts with understanding the user's actual needs
