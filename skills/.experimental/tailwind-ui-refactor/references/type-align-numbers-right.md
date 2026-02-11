---
title: Right-Align Numbers in Tables for Easy Comparison
impact: MEDIUM
impactDescription: enables instant visual comparison of numeric values
tags: type, alignment, tables, numbers, data
---

Numbers in table columns should be right-aligned so decimal points and digit places line up. Left-aligned numbers make it hard to compare values quickly.

**Incorrect (left-aligned numbers):**
```html
<table class="w-full">
  <thead>
    <tr class="border-b text-left text-sm text-gray-500">
      <th class="pb-2">Product</th>
      <th class="pb-2">Revenue</th>
      <th class="pb-2">Units</th>
    </tr>
  </thead>
  <tbody class="text-sm">
    <tr class="border-b"><td class="py-2">Widget A</td><td class="py-2">$1,234.56</td><td class="py-2">150</td></tr>
    <tr class="border-b"><td class="py-2">Widget B</td><td class="py-2">$98.00</td><td class="py-2">2,340</td></tr>
    <tr class="border-b"><td class="py-2">Widget C</td><td class="py-2">$12,456.78</td><td class="py-2">89</td></tr>
  </tbody>
</table>
```

**Correct (right-aligned numbers, left-aligned labels):**
```html
<table class="w-full">
  <thead>
    <tr class="border-b text-sm text-gray-500">
      <th class="pb-2 text-left">Product</th>
      <th class="pb-2 text-right">Revenue</th>
      <th class="pb-2 text-right">Units</th>
    </tr>
  </thead>
  <tbody class="text-sm">
    <tr class="border-b"><td class="py-2">Widget A</td><td class="py-2 text-right tabular-nums">$1,234.56</td><td class="py-2 text-right tabular-nums">150</td></tr>
    <tr class="border-b"><td class="py-2">Widget B</td><td class="py-2 text-right tabular-nums">$98.00</td><td class="py-2 text-right tabular-nums">2,340</td></tr>
    <tr class="border-b"><td class="py-2">Widget C</td><td class="py-2 text-right tabular-nums">$12,456.78</td><td class="py-2 text-right tabular-nums">89</td></tr>
  </tbody>
</table>
```

Reference: Refactoring UI — "Designing Text"
