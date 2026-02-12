---
title: Use Visual Breakpoint Indicators During Development
impact: LOW-MEDIUM
impactDescription: catches 80% of breakpoint bugs during development
tags: bp, debugging, development, devtools, indicators
---

## Use Visual Breakpoint Indicators During Development

When testing responsive layouts, manually resizing the browser and guessing which breakpoint is active leads to missed bugs -- you think you are testing `md:` but you are actually 2px into `lg:`. A small fixed indicator that shows the current active breakpoint removes guesswork and catches missing responsive styles before they reach production.

**Incorrect (guessing which breakpoint is active while resizing):**

```html
<!-- No breakpoint indicator — developer resizes browser and guesses -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 p-4">
  <div class="rounded-lg border p-4">Card 1</div>
  <div class="rounded-lg border p-4">Card 2</div>
  <div class="rounded-lg border p-4">Card 3</div>
  <!-- Bug: missing md:grid-cols-2 override, but developer can't tell
       when they've crossed from sm to md to lg while dragging -->
</div>
```

**Correct (dev-only breakpoint indicator in corner):**

```html
<!-- Drop this component in your layout during development, remove before production.
     Only one label is visible at a time using Tailwind's hidden/block utilities. -->
<div class="fixed bottom-1 left-1 z-50 flex h-6 items-center rounded-full bg-gray-900 px-2.5 text-xs font-mono text-white opacity-80">
  <span class="sm:hidden">xs</span>
  <span class="hidden sm:block md:hidden">sm</span>
  <span class="hidden md:block lg:hidden">md</span>
  <span class="hidden lg:block xl:hidden">lg</span>
  <span class="hidden xl:block 2xl:hidden">xl</span>
  <span class="hidden 2xl:block">2xl</span>
</div>

<!-- Now the grid bug is immediately obvious:
     the indicator shows "md" but grid is still 2-col from sm -->
<div class="grid grid-cols-1 gap-4 p-4 sm:grid-cols-2 md:grid-cols-2 lg:grid-cols-3">
  <div class="rounded-lg border p-4">Card 1</div>
  <div class="rounded-lg border p-4">Card 2</div>
  <div class="rounded-lg border p-4">Card 3</div>
</div>
```

**Tip:** Wrap the indicator in a conditional so it is automatically excluded from production builds:

```html
<!-- Vite example: only rendered in dev mode -->
<div v-if="import.meta.env.DEV" class="fixed bottom-1 left-1 z-50 ...">
  <!-- breakpoint labels -->
</div>
```
