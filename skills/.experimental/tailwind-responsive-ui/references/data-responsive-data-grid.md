---
title: Adapt Data Grid Density for Screen Size
impact: LOW-MEDIUM
impactDescription: reduces visible columns from 8 to 3-4 on mobile
tags: data, grid, dashboard, density, responsive
---

## Adapt Data Grid Density for Screen Size

Data grids in dashboards and admin panels need different information density at different screen sizes. Showing all 8 columns on a 375px screen forces text into 40px-wide cells — unreadable and useless. Instead, show only the 3-4 most essential columns on mobile with a "view details" affordance, then progressively reveal more columns as the viewport widens. This keeps mobile scannable while preserving the full data experience on desktop.

**Incorrect (all columns shown regardless of screen size):**

```html
<!-- 8 columns at ~80px each need 640px+ — tiny unreadable text on mobile -->
<table class="w-full border-collapse text-sm">
  <thead>
    <tr class="border-b bg-gray-50 text-left text-xs font-medium text-gray-500">
      <th class="px-3 py-3">Order ID</th>
      <th class="px-3 py-3">Customer</th>
      <th class="px-3 py-3">Email</th>
      <th class="px-3 py-3">Product</th>
      <th class="px-3 py-3">Quantity</th>
      <th class="px-3 py-3">Total</th>
      <th class="px-3 py-3">Date</th>
      <th class="px-3 py-3">Status</th>
    </tr>
  </thead>
  <tbody>
    <tr class="border-b">
      <td class="px-3 py-3 text-gray-900">#4821</td>
      <td class="px-3 py-3 text-gray-900">Sarah Chen</td>
      <td class="px-3 py-3 text-gray-600">sarah.chen@example.com</td>
      <td class="px-3 py-3 text-gray-600">Pro Annual Plan</td>
      <td class="px-3 py-3 text-gray-600">1</td>
      <td class="px-3 py-3 text-gray-900">$299.00</td>
      <td class="px-3 py-3 text-gray-600">2025-01-15</td>
      <td class="px-3 py-3"><span class="rounded-full bg-green-100 px-2 py-0.5 text-xs text-green-700">Paid</span></td>
    </tr>
    <tr class="border-b">
      <td class="px-3 py-3 text-gray-900">#4820</td>
      <td class="px-3 py-3 text-gray-900">Marcus Johnson</td>
      <td class="px-3 py-3 text-gray-600">m.johnson@example.com</td>
      <td class="px-3 py-3 text-gray-600">Starter Monthly</td>
      <td class="px-3 py-3 text-gray-600">3</td>
      <td class="px-3 py-3 text-gray-900">$87.00</td>
      <td class="px-3 py-3 text-gray-600">2025-01-14</td>
      <td class="px-3 py-3"><span class="rounded-full bg-yellow-100 px-2 py-0.5 text-xs text-yellow-700">Pending</span></td>
    </tr>
  </tbody>
</table>
```

**Correct (progressive column reveal with mobile "view details" action):**

```html
<div class="overflow-x-auto">
  <table class="w-full border-collapse text-sm">
    <thead>
      <tr class="border-b bg-gray-50 text-left text-xs font-medium text-gray-500">
        <th class="px-3 py-3">Order</th>
        <th class="px-3 py-3">Customer</th>
        <!-- Hidden on mobile, shown from md up -->
        <th class="hidden px-3 py-3 md:table-cell">Email</th>
        <th class="hidden px-3 py-3 lg:table-cell">Product</th>
        <th class="hidden px-3 py-3 lg:table-cell">Qty</th>
        <th class="px-3 py-3">Total</th>
        <th class="hidden px-3 py-3 md:table-cell">Date</th>
        <th class="px-3 py-3">Status</th>
        <!-- Mobile-only details column -->
        <th class="px-3 py-3 md:hidden"><span class="sr-only">Details</span></th>
      </tr>
    </thead>
    <tbody>
      <tr class="border-b">
        <td class="px-3 py-3 font-medium text-gray-900">#4821</td>
        <td class="px-3 py-3 text-gray-900">Sarah Chen</td>
        <td class="hidden px-3 py-3 text-gray-600 md:table-cell">sarah.chen@example.com</td>
        <td class="hidden px-3 py-3 text-gray-600 lg:table-cell">Pro Annual Plan</td>
        <td class="hidden px-3 py-3 text-gray-600 lg:table-cell">1</td>
        <td class="px-3 py-3 font-medium text-gray-900">$299.00</td>
        <td class="hidden px-3 py-3 text-gray-600 md:table-cell">Jan 15</td>
        <td class="px-3 py-3"><span class="rounded-full bg-green-100 px-2 py-0.5 text-xs text-green-700">Paid</span></td>
        <td class="px-3 py-3 md:hidden">
          <button class="text-blue-600 hover:text-blue-800" aria-label="View order #4821 details">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </td>
      </tr>
      <tr class="border-b">
        <td class="px-3 py-3 font-medium text-gray-900">#4820</td>
        <td class="px-3 py-3 text-gray-900">Marcus Johnson</td>
        <td class="hidden px-3 py-3 text-gray-600 md:table-cell">m.johnson@example.com</td>
        <td class="hidden px-3 py-3 text-gray-600 lg:table-cell">Starter Monthly</td>
        <td class="hidden px-3 py-3 text-gray-600 lg:table-cell">3</td>
        <td class="px-3 py-3 font-medium text-gray-900">$87.00</td>
        <td class="hidden px-3 py-3 text-gray-600 md:table-cell">Jan 14</td>
        <td class="px-3 py-3"><span class="rounded-full bg-yellow-100 px-2 py-0.5 text-xs text-yellow-700">Pending</span></td>
        <td class="px-3 py-3 md:hidden">
          <button class="text-blue-600 hover:text-blue-800" aria-label="View order #4820 details">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </td>
      </tr>
    </tbody>
  </table>
</div>
```

**Key principle:** Use `hidden md:table-cell` and `hidden lg:table-cell` to progressively reveal columns at wider breakpoints. Keep 3-4 essential columns always visible (identifier, name, key metric, status) and add a mobile-only chevron button (`md:hidden`) that links to a detail view. This keeps the mobile grid scannable without losing access to any data.
