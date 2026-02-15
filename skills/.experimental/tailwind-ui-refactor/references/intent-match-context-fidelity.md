---
title: Match Design Fidelity to UI Context — Admin vs Consumer vs Product
impact: CRITICAL
impactDescription: prevents over-engineering admin UIs and under-designing consumer UIs by calibrating effort to context
tags: intent, context, admin, consumer, fidelity, scope
---

Not all UIs deserve the same level of design polish. An admin dashboard, a consumer marketing page, and a product interface have fundamentally different design budgets. Apply the right level of effort to the right context.

**Context decision tree — before applying any styling rules, determine the UI context:**

| Context | Goal | Skip Categories | Spacing | Polish Level |
|---------|------|-----------------|---------|--------------|
| **Admin/Internal** | Information density, fast scanning | Polish & Details, most of Depth & Shadows | Dense — prefer compact spacing | Minimal — function over form |
| **Product/App** | Clarity, usability, brand consistency | None, but apply Polish sparingly | Balanced — systematic scale | Moderate — polish where users linger |
| **Consumer/Marketing** | Engagement, conversion, brand impression | None — apply all categories | Generous — start with more space | Maximum — every detail matters |

**Incorrect (applying full polish to an admin data table):**
```html
<table class="w-full">
  <tbody class="divide-y divide-gray-100">
    <tr>
      <td class="py-4 px-6">
        <div class="flex items-center gap-3">
          <div class="flex h-10 w-10 items-center justify-center rounded-full bg-blue-100">
            <svg class="h-5 w-5 text-blue-600"><!-- icon --></svg>
          </div>
          <div>
            <p class="font-semibold text-gray-900">Order #4521</p>
            <p class="text-sm text-gray-500">March 12, 2025</p>
          </div>
        </div>
      </td>
      <td class="py-4 px-6">
        <span class="rounded-full bg-green-100 px-3 py-1 text-xs font-medium text-green-700">Completed</span>
      </td>
    </tr>
  </tbody>
</table>
```

**Correct (dense, functional admin table — no unnecessary decoration):**
```html
<table class="w-full text-sm">
  <tbody class="divide-y divide-gray-200">
    <tr>
      <td class="py-2 px-3 font-medium text-gray-900">#4521</td>
      <td class="py-2 px-3 text-gray-600">Mar 12, 2025</td>
      <td class="py-2 px-3">
        <span class="text-xs font-medium text-green-700">Completed</span>
      </td>
    </tr>
  </tbody>
</table>
```

For admin UIs: prefer density over generosity, skip icon circles and decorative wrappers, use inline status text instead of badge pills, and keep padding tight (py-2 px-3 instead of py-4 px-6). Every element should earn its space by serving a scanning or action purpose.

Reference: Refactoring UI — "Start with a Feature, Not a Layout"
