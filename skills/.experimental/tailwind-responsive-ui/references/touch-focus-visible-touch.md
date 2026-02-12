---
title: Use focus-visible for Touch-Friendly Focus Styles
impact: LOW-MEDIUM
impactDescription: eliminates 100% of unwanted tap focus rings on mobile
tags: touch, focus, accessibility, keyboard, mobile
---

## Use focus-visible for Touch-Friendly Focus Styles

The default `:focus` pseudo-class triggers on every focus event — including taps and clicks on mobile — which leaves distracting outline rings on buttons and links after every interaction. This looks unpolished and confuses users who wonder why a ring appeared. The `:focus-visible` pseudo-class (Tailwind's `focus-visible:` variant) only applies focus styles when the browser detects keyboard navigation, preserving full accessibility for keyboard and assistive-technology users while keeping the tap experience clean on touch devices.

**Incorrect (focus ring appears on every tap and click):**

```html
<!-- Every tap on mobile leaves a visible blue ring around the button until the user taps elsewhere -->
<nav class="flex gap-2 p-4">
  <a href="/home" class="rounded-lg px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
    Home
  </a>
  <a href="/explore" class="rounded-lg px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
    Explore
  </a>
</nav>

<button class="rounded-lg bg-blue-600 px-6 py-3 text-sm font-semibold text-white focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
  Subscribe
</button>
```

**Correct (focus ring only for keyboard navigation, clean on touch):**

```html
<!-- focus-visible: only triggers for keyboard users — no ring on tap, full accessibility preserved -->
<nav class="flex gap-2 p-4">
  <a href="/home" class="rounded-lg px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-offset-2">
    Home
  </a>
  <a href="/explore" class="rounded-lg px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-offset-2">
    Explore
  </a>
</nav>

<button class="rounded-lg bg-blue-600 px-6 py-3 text-sm font-semibold text-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-offset-2">
  Subscribe
</button>
```
