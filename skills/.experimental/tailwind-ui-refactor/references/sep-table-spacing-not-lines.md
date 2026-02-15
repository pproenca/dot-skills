---
title: Use Spacing Instead of Lines in Simple Tables
impact: MEDIUM
impactDescription: replaces per-cell border utilities in data tables with spacing and a single divide-y
tags: sep, tables, spacing, lines, data-display
---

Dense tables with borders on every cell feel heavy and old-fashioned. For simple data tables, remove most borders and use generous padding. Only keep a subtle header border. For complex tables with sorting, horizontal rules between rows are acceptable.

**Incorrect (heavy borders on all cells):**
```html
<table class="w-full border-collapse border">
  <thead>
    <tr class="bg-gray-100">
      <th class="border px-4 py-2 text-left text-sm font-bold">Name</th>
      <th class="border px-4 py-2 text-left text-sm font-bold">Role</th>
      <th class="border px-4 py-2 text-left text-sm font-bold">Email</th>
    </tr>
  </thead>
  <tbody>
    <tr><td class="border px-4 py-2 text-sm">Alice</td><td class="border px-4 py-2 text-sm">Engineer</td><td class="border px-4 py-2 text-sm">alice@co.com</td></tr>
    <tr><td class="border px-4 py-2 text-sm">Bob</td><td class="border px-4 py-2 text-sm">Designer</td><td class="border px-4 py-2 text-sm">bob@co.com</td></tr>
  </tbody>
</table>
```

**Correct (minimal lines, generous spacing):**
```html
<table class="w-full">
  <thead>
    <tr class="border-b border-gray-200">
      <th class="pb-3 text-left text-xs font-medium uppercase tracking-wide text-gray-500">Name</th>
      <th class="pb-3 text-left text-xs font-medium uppercase tracking-wide text-gray-500">Role</th>
      <th class="pb-3 text-left text-xs font-medium uppercase tracking-wide text-gray-500">Email</th>
    </tr>
  </thead>
  <tbody class="divide-y divide-gray-100">
    <tr><td class="py-3 text-sm text-gray-900">Alice</td><td class="py-3 text-sm text-gray-600">Engineer</td><td class="py-3 text-sm text-gray-500">alice@co.com</td></tr>
    <tr><td class="py-3 text-sm text-gray-900">Bob</td><td class="py-3 text-sm text-gray-600">Designer</td><td class="py-3 text-sm text-gray-500">bob@co.com</td></tr>
  </tbody>
</table>
```

Reference: Refactoring UI — "Finishing Touches"
