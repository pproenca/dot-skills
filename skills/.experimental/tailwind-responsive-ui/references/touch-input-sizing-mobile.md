---
title: Size Form Inputs to Prevent iOS Zoom
impact: MEDIUM-HIGH
impactDescription: prevents unwanted page zoom on iOS (affects 50%+ mobile users)
tags: touch, forms, ios, zoom, input, mobile
---

## Size Form Inputs to Prevent iOS Zoom

iOS Safari automatically zooms the page when a user focuses a form input with a computed font-size below 16px. This zoom is disorienting, shifts the layout, and requires a manual pinch-to-zoom-out to return to the original view. Since over 50% of mobile traffic comes from iOS devices, this is one of the most impactful mobile UX bugs. The fix is simple: use `text-base` (16px) for inputs on mobile and scale down to `text-sm` on desktop where auto-zoom is not an issue.

**Incorrect (text-sm triggers iOS auto-zoom on focus):**

```html
<!-- text-sm = 14px on mobile — iOS Safari will zoom the page when user taps any input -->
<form class="space-y-4 p-4">
  <div>
    <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
    <input
      type="email"
      id="email"
      placeholder="you@example.com"
      class="mt-1 block w-full rounded-md border border-gray-300 px-3 py-1.5 text-sm shadow-sm focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
    />
  </div>
  <div>
    <label for="password" class="block text-sm font-medium text-gray-700">Password</label>
    <input
      type="password"
      id="password"
      placeholder="Enter your password"
      class="mt-1 block w-full rounded-md border border-gray-300 px-3 py-1.5 text-sm shadow-sm focus:border-blue-500 focus:ring-1 focus:ring-blue-500"
    />
  </div>
  <button type="submit" class="w-full rounded-md bg-blue-600 px-4 py-1.5 text-sm font-medium text-white">
    Sign In
  </button>
</form>
```

**Correct (text-base on mobile prevents zoom, text-sm on desktop for compact layout):**

```html
<!-- text-base (16px) on mobile prevents iOS zoom, text-sm on desktop where zoom isn't an issue -->
<form class="space-y-4 p-4">
  <div>
    <label for="email" class="block text-base font-medium text-gray-700 md:text-sm">Email</label>
    <input
      type="email"
      id="email"
      placeholder="you@example.com"
      class="mt-1 block h-12 w-full rounded-md border border-gray-300 px-3 py-2 text-base shadow-sm focus:border-blue-500 focus:ring-1 focus:ring-blue-500 md:h-10 md:py-1.5 md:text-sm"
    />
  </div>
  <div>
    <label for="password" class="block text-base font-medium text-gray-700 md:text-sm">Password</label>
    <input
      type="password"
      id="password"
      placeholder="Enter your password"
      class="mt-1 block h-12 w-full rounded-md border border-gray-300 px-3 py-2 text-base shadow-sm focus:border-blue-500 focus:ring-1 focus:ring-blue-500 md:h-10 md:py-1.5 md:text-sm"
    />
  </div>
  <button type="submit" class="h-12 w-full rounded-md bg-blue-600 px-4 py-2 text-base font-medium text-white md:h-10 md:py-1.5 md:text-sm">
    Sign In
  </button>
</form>
```
