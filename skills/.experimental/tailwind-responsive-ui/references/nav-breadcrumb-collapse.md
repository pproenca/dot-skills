---
title: Truncate Breadcrumbs on Mobile
impact: MEDIUM
impactDescription: prevents breadcrumb wrapping that wastes vertical space
tags: nav, breadcrumbs, truncation, mobile, responsive
---

## Truncate Breadcrumbs on Mobile

Long breadcrumb trails (Home > Category > Subcategory > Product > Details) overflow on mobile, wrapping to 2-3 lines and consuming precious vertical space above the actual content. Users rarely need the full trail on mobile — showing the first crumb, an ellipsis for collapsed middle items, and the last 1-2 crumbs provides enough context to navigate back while keeping the breadcrumb to a single line.

**Incorrect (full breadcrumb trail wraps to multiple lines on mobile):**

```html
<!-- Five breadcrumb items at ~60-100px each overflow a 375px screen, wrapping to 2-3 lines -->
<nav aria-label="Breadcrumb" class="px-4 py-3">
  <ol class="flex flex-wrap items-center gap-2 text-sm text-gray-600">
    <li><a href="/" class="hover:text-gray-900">Home</a></li>
    <li class="before:mr-2 before:content-['/']">
      <a href="/electronics" class="hover:text-gray-900">Electronics</a>
    </li>
    <li class="before:mr-2 before:content-['/']">
      <a href="/electronics/computers" class="hover:text-gray-900">Computers & Tablets</a>
    </li>
    <li class="before:mr-2 before:content-['/']">
      <a href="/electronics/computers/laptops" class="hover:text-gray-900">Laptops</a>
    </li>
    <li class="before:mr-2 before:content-['/'] font-medium text-gray-900" aria-current="page">
      MacBook Pro 16-inch
    </li>
  </ol>
</nav>
```

**Correct (collapsed middle items on mobile, full trail on desktop):**

```html
<!-- Middle breadcrumb items hidden on mobile, replaced by an ellipsis indicator -->
<nav aria-label="Breadcrumb" class="px-4 py-3">
  <ol class="flex items-center gap-2 text-sm text-gray-600">
    <!-- First item — always visible -->
    <li>
      <a href="/" class="hover:text-gray-900">Home</a>
    </li>

    <!-- Middle items — hidden on mobile, shown from md up -->
    <li class="hidden before:mr-2 before:content-['/'] md:list-item">
      <a href="/electronics" class="hover:text-gray-900">Electronics</a>
    </li>
    <li class="hidden before:mr-2 before:content-['/'] md:list-item">
      <a href="/electronics/computers" class="hover:text-gray-900">Computers & Tablets</a>
    </li>

    <!-- Ellipsis — shown only on mobile to indicate collapsed items -->
    <li class="before:mr-2 before:content-['/'] md:hidden">
      <span class="text-gray-400" aria-label="collapsed breadcrumb items">...</span>
    </li>

    <!-- Last parent — always visible for one-tap back navigation -->
    <li class="before:mr-2 before:content-['/']">
      <a href="/electronics/computers/laptops" class="hover:text-gray-900">Laptops</a>
    </li>

    <!-- Current page — always visible -->
    <li class="before:mr-2 before:content-['/'] font-medium text-gray-900" aria-current="page">
      MacBook Pro 16-inch
    </li>
  </ol>
</nav>
```

**Key principle:** Use `hidden md:list-item` on middle breadcrumb items to hide them on mobile and restore them on desktop. Add a `md:hidden` ellipsis `<li>` between the first crumb and the last parent. Always keep the first item (root) and last 1-2 items visible so the user can orient and navigate back.
