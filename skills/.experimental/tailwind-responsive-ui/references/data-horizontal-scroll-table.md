---
title: Use Horizontal Scroll for Dense Data Tables
impact: LOW-MEDIUM
impactDescription: preserves data relationships without cramming columns
tags: data, tables, scroll, overflow, responsive
---

## Use Horizontal Scroll for Dense Data Tables

When table data must stay in tabular format — financial data, comparison matrices, spreadsheet-like views — breaking the table into cards destroys the column alignment that gives the data meaning. Instead, wrap the table in a horizontally scrollable container so users can pan through columns while row headers stay contextually linked. This preserves data integrity without shrinking columns to unreadable widths.

**Incorrect (table shrinks columns until text wraps and becomes unreadable):**

```html
<!-- Columns compress to fit 375px — text wraps, numbers misalign, layout breaks -->
<div class="px-4">
  <table class="w-full border-collapse text-sm">
    <thead>
      <tr class="border-b bg-gray-50 text-left text-xs font-medium uppercase text-gray-500">
        <th class="px-3 py-3">Product</th>
        <th class="px-3 py-3">Q1 Revenue</th>
        <th class="px-3 py-3">Q2 Revenue</th>
        <th class="px-3 py-3">Q3 Revenue</th>
        <th class="px-3 py-3">Q4 Revenue</th>
        <th class="px-3 py-3">YoY Growth</th>
        <th class="px-3 py-3">Margin</th>
      </tr>
    </thead>
    <tbody>
      <tr class="border-b">
        <td class="px-3 py-3 font-medium text-gray-900">Enterprise Plan</td>
        <td class="px-3 py-3 text-gray-600">$1,245,000</td>
        <td class="px-3 py-3 text-gray-600">$1,389,200</td>
        <td class="px-3 py-3 text-gray-600">$1,502,750</td>
        <td class="px-3 py-3 text-gray-600">$1,678,400</td>
        <td class="px-3 py-3 text-green-600">+34.8%</td>
        <td class="px-3 py-3 text-gray-600">72.3%</td>
      </tr>
      <tr class="border-b">
        <td class="px-3 py-3 font-medium text-gray-900">Starter Plan</td>
        <td class="px-3 py-3 text-gray-600">$423,100</td>
        <td class="px-3 py-3 text-gray-600">$456,800</td>
        <td class="px-3 py-3 text-gray-600">$498,200</td>
        <td class="px-3 py-3 text-gray-600">$512,600</td>
        <td class="px-3 py-3 text-green-600">+21.2%</td>
        <td class="px-3 py-3 text-gray-600">68.1%</td>
      </tr>
    </tbody>
  </table>
</div>
```

**Correct (horizontal scroll container with edge-to-edge bleed on mobile):**

```html
<!-- Negative margins let the table bleed to screen edges on mobile for maximum width -->
<div class="overflow-x-auto -mx-4 px-4 md:mx-0 md:px-0">
  <table class="min-w-[700px] w-full border-collapse text-sm">
    <thead>
      <tr class="border-b bg-gray-50 text-left text-xs font-medium uppercase text-gray-500">
        <th class="whitespace-nowrap px-3 py-3">Product</th>
        <th class="whitespace-nowrap px-3 py-3">Q1 Revenue</th>
        <th class="whitespace-nowrap px-3 py-3">Q2 Revenue</th>
        <th class="whitespace-nowrap px-3 py-3">Q3 Revenue</th>
        <th class="whitespace-nowrap px-3 py-3">Q4 Revenue</th>
        <th class="whitespace-nowrap px-3 py-3">YoY Growth</th>
        <th class="whitespace-nowrap px-3 py-3">Margin</th>
      </tr>
    </thead>
    <tbody>
      <tr class="border-b">
        <td class="whitespace-nowrap px-3 py-3 font-medium text-gray-900">Enterprise Plan</td>
        <td class="whitespace-nowrap px-3 py-3 tabular-nums text-gray-600">$1,245,000</td>
        <td class="whitespace-nowrap px-3 py-3 tabular-nums text-gray-600">$1,389,200</td>
        <td class="whitespace-nowrap px-3 py-3 tabular-nums text-gray-600">$1,502,750</td>
        <td class="whitespace-nowrap px-3 py-3 tabular-nums text-gray-600">$1,678,400</td>
        <td class="whitespace-nowrap px-3 py-3 tabular-nums text-green-600">+34.8%</td>
        <td class="whitespace-nowrap px-3 py-3 tabular-nums text-gray-600">72.3%</td>
      </tr>
      <tr class="border-b">
        <td class="whitespace-nowrap px-3 py-3 font-medium text-gray-900">Starter Plan</td>
        <td class="whitespace-nowrap px-3 py-3 tabular-nums text-gray-600">$423,100</td>
        <td class="whitespace-nowrap px-3 py-3 tabular-nums text-gray-600">$456,800</td>
        <td class="whitespace-nowrap px-3 py-3 tabular-nums text-gray-600">$498,200</td>
        <td class="whitespace-nowrap px-3 py-3 tabular-nums text-gray-600">$512,600</td>
        <td class="whitespace-nowrap px-3 py-3 tabular-nums text-green-600">+21.2%</td>
        <td class="whitespace-nowrap px-3 py-3 tabular-nums text-gray-600">68.1%</td>
      </tr>
    </tbody>
  </table>
</div>
```

**Key principle:** The pattern is `overflow-x-auto` on the wrapper plus `min-w-[...]` on the table to set a minimum readable width. The `-mx-4 px-4 md:mx-0 md:px-0` trick pulls the scrollable area to the screen edges on mobile, giving the table the full viewport width. Use `whitespace-nowrap` on cells to prevent awkward line breaks within data, and `tabular-nums` for proper number alignment.
