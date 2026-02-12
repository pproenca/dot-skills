---
title: Transform Tables to Cards on Mobile
impact: LOW-MEDIUM
impactDescription: eliminates horizontal scrolling on 100% of mobile screens
tags: data, tables, cards, mobile-first, responsive
---

## Transform Tables to Cards on Mobile

Wide tables with 5+ columns are unusable on mobile — users see only 2 columns and must scroll horizontally to access the rest, losing context between the row identifier and the data they need. Converting each table row into a self-contained card on mobile lets users scan vertically through complete records instead of scrolling in two dimensions.

**Incorrect (standard table forces horizontal scrolling on mobile):**

```html
<!-- 5 columns at ~100-150px each need ~600px minimum — overflows a 375px screen -->
<table class="w-full border-collapse">
  <thead>
    <tr class="border-b bg-gray-50 text-left text-sm font-medium text-gray-500">
      <th class="px-4 py-3">Name</th>
      <th class="px-4 py-3">Email</th>
      <th class="px-4 py-3">Role</th>
      <th class="px-4 py-3">Status</th>
      <th class="px-4 py-3">Actions</th>
    </tr>
  </thead>
  <tbody>
    <tr class="border-b text-sm">
      <td class="px-4 py-3 font-medium text-gray-900">Sarah Chen</td>
      <td class="px-4 py-3 text-gray-600">sarah.chen@company.com</td>
      <td class="px-4 py-3 text-gray-600">Engineering Lead</td>
      <td class="px-4 py-3"><span class="rounded-full bg-green-100 px-2 py-1 text-xs text-green-700">Active</span></td>
      <td class="px-4 py-3"><button class="text-blue-600 hover:text-blue-800">Edit</button></td>
    </tr>
    <tr class="border-b text-sm">
      <td class="px-4 py-3 font-medium text-gray-900">Marcus Johnson</td>
      <td class="px-4 py-3 text-gray-600">m.johnson@company.com</td>
      <td class="px-4 py-3 text-gray-600">Product Manager</td>
      <td class="px-4 py-3"><span class="rounded-full bg-yellow-100 px-2 py-1 text-xs text-yellow-700">Pending</span></td>
      <td class="px-4 py-3"><button class="text-blue-600 hover:text-blue-800">Edit</button></td>
    </tr>
  </tbody>
</table>
```

**Correct (cards on mobile, table on desktop using dual-view approach):**

```html
<!-- Desktop table — hidden on mobile, shown from md up -->
<table class="hidden w-full border-collapse md:table">
  <thead>
    <tr class="border-b bg-gray-50 text-left text-sm font-medium text-gray-500">
      <th class="px-4 py-3">Name</th>
      <th class="px-4 py-3">Email</th>
      <th class="px-4 py-3">Role</th>
      <th class="px-4 py-3">Status</th>
      <th class="px-4 py-3">Actions</th>
    </tr>
  </thead>
  <tbody>
    <tr class="border-b text-sm">
      <td class="px-4 py-3 font-medium text-gray-900">Sarah Chen</td>
      <td class="px-4 py-3 text-gray-600">sarah.chen@company.com</td>
      <td class="px-4 py-3 text-gray-600">Engineering Lead</td>
      <td class="px-4 py-3"><span class="rounded-full bg-green-100 px-2 py-1 text-xs text-green-700">Active</span></td>
      <td class="px-4 py-3"><button class="text-blue-600 hover:text-blue-800">Edit</button></td>
    </tr>
    <tr class="border-b text-sm">
      <td class="px-4 py-3 font-medium text-gray-900">Marcus Johnson</td>
      <td class="px-4 py-3 text-gray-600">m.johnson@company.com</td>
      <td class="px-4 py-3 text-gray-600">Product Manager</td>
      <td class="px-4 py-3"><span class="rounded-full bg-yellow-100 px-2 py-1 text-xs text-yellow-700">Pending</span></td>
      <td class="px-4 py-3"><button class="text-blue-600 hover:text-blue-800">Edit</button></td>
    </tr>
  </tbody>
</table>

<!-- Mobile cards — shown on mobile, hidden from md up -->
<div class="flex flex-col gap-3 md:hidden">
  <div class="rounded-lg border bg-white p-4 shadow-sm">
    <div class="flex items-center justify-between">
      <h3 class="font-medium text-gray-900">Sarah Chen</h3>
      <span class="rounded-full bg-green-100 px-2 py-1 text-xs text-green-700">Active</span>
    </div>
    <p class="mt-1 text-sm text-gray-600">sarah.chen@company.com</p>
    <p class="mt-1 text-sm text-gray-500">Engineering Lead</p>
    <div class="mt-3 border-t pt-3">
      <button class="text-sm font-medium text-blue-600 hover:text-blue-800">Edit</button>
    </div>
  </div>
  <div class="rounded-lg border bg-white p-4 shadow-sm">
    <div class="flex items-center justify-between">
      <h3 class="font-medium text-gray-900">Marcus Johnson</h3>
      <span class="rounded-full bg-yellow-100 px-2 py-1 text-xs text-yellow-700">Pending</span>
    </div>
    <p class="mt-1 text-sm text-gray-600">m.johnson@company.com</p>
    <p class="mt-1 text-sm text-gray-500">Product Manager</p>
    <div class="mt-3 border-t pt-3">
      <button class="text-sm font-medium text-blue-600 hover:text-blue-800">Edit</button>
    </div>
  </div>
</div>
```

**Key principle:** Use `hidden md:table` on the desktop table and `md:hidden` on the mobile card container. This dual-view approach avoids CSS hacks with `display: block` on table elements and gives you full control over the card layout. For server-rendered pages, consider generating both views from the same data source to avoid duplication.
