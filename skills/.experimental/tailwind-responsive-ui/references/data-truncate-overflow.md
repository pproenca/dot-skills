---
title: Truncate Overflowing Text on Mobile
impact: LOW-MEDIUM
impactDescription: prevents layout breaks from long content
tags: data, text, truncation, overflow, responsive
---

## Truncate Overflowing Text on Mobile

Long strings like email addresses, URLs, file paths, and product names break mobile layouts by forcing containers wider than the viewport or wrapping into multiple lines that destroy the visual rhythm. A 40-character email in a 160px-wide column either overflows or stacks into 3 lines. Truncating with ellipsis on mobile preserves the layout while still showing enough of the content for identification, with full text available on hover or on wider screens.

**Incorrect (full-length text wraps and breaks card layout on mobile):**

```html
<ul class="divide-y divide-gray-200">
  <li class="flex items-center justify-between gap-4 px-4 py-3">
    <div>
      <p class="text-sm font-medium text-gray-900">Sarah Chen</p>
      <!-- 30+ character email wraps to 2 lines on mobile, misaligning the row -->
      <p class="text-sm text-gray-500">sarah.chen.engineering@longcompanyname.com</p>
    </div>
    <span class="rounded-full bg-green-100 px-2 py-1 text-xs text-green-700">Active</span>
  </li>
  <li class="flex items-center justify-between gap-4 px-4 py-3">
    <div>
      <p class="text-sm font-medium text-gray-900">Alexander Konstantinidis</p>
      <!-- Long name + long email = 4 lines of text on mobile for a single list item -->
      <p class="text-sm text-gray-500">alexander.konstantinidis@international-corp.co.uk</p>
    </div>
    <span class="rounded-full bg-yellow-100 px-2 py-1 text-xs text-yellow-700">Pending</span>
  </li>
  <li class="flex items-center justify-between gap-4 px-4 py-3">
    <div>
      <p class="text-sm font-medium text-gray-900">Documentation Update</p>
      <!-- URLs are the worst offenders — no natural break points -->
      <p class="text-sm text-gray-500">https://github.com/organization/repository-name/pull/1234/files#diff-abc123</p>
    </div>
    <span class="rounded-full bg-blue-100 px-2 py-1 text-xs text-blue-700">Review</span>
  </li>
</ul>
```

**Correct (truncated on mobile, full text on desktop):**

```html
<ul class="divide-y divide-gray-200">
  <li class="flex items-center justify-between gap-4 px-4 py-3">
    <!-- min-w-0 is critical — allows flex child to shrink below its content size -->
    <div class="min-w-0 flex-1">
      <p class="truncate text-sm font-medium text-gray-900">Sarah Chen</p>
      <!-- truncate clips at container edge, line-clamp-1 md:line-clamp-none for multi-line control -->
      <p class="truncate text-sm text-gray-500 md:overflow-visible md:text-clip md:whitespace-normal">
        sarah.chen.engineering@longcompanyname.com
      </p>
    </div>
    <span class="shrink-0 rounded-full bg-green-100 px-2 py-1 text-xs text-green-700">Active</span>
  </li>
  <li class="flex items-center justify-between gap-4 px-4 py-3">
    <div class="min-w-0 flex-1">
      <p class="truncate text-sm font-medium text-gray-900">Alexander Konstantinidis</p>
      <p class="truncate text-sm text-gray-500 md:overflow-visible md:text-clip md:whitespace-normal">
        alexander.konstantinidis@international-corp.co.uk
      </p>
    </div>
    <span class="shrink-0 rounded-full bg-yellow-100 px-2 py-1 text-xs text-yellow-700">Pending</span>
  </li>
  <li class="flex items-center justify-between gap-4 px-4 py-3">
    <div class="min-w-0 flex-1">
      <p class="truncate text-sm font-medium text-gray-900">Documentation Update</p>
      <!-- line-clamp-1 on mobile, full text on desktop -->
      <p class="line-clamp-1 text-sm text-gray-500 md:line-clamp-none">
        https://github.com/organization/repository-name/pull/1234/files#diff-abc123
      </p>
    </div>
    <span class="shrink-0 rounded-full bg-blue-100 px-2 py-1 text-xs text-blue-700">Review</span>
  </li>
</ul>
```

**Key principle:** Three utilities work together: `min-w-0` on the flex child (allows it to shrink below content width), `truncate` on the text element (sets `overflow-hidden text-ellipsis whitespace-nowrap`), and `shrink-0` on badges or actions so they never collapse. Use `line-clamp-1 md:line-clamp-none` when you want to allow wrapping on desktop but restrict to one line on mobile. Always add `md:overflow-visible md:text-clip md:whitespace-normal` to undo truncation at wider breakpoints when full text should be visible.
