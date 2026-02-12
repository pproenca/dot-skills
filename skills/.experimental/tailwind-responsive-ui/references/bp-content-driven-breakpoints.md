---
title: Set Breakpoints Where Content Breaks
impact: CRITICAL
impactDescription: eliminates layout breakage between standard breakpoints
tags: bp, content-driven, custom-breakpoints, layout-integrity
---

## Set Breakpoints Where Content Breaks

Don't choose breakpoints based on popular device widths. Instead, resize your content until it looks bad -- text overflows, cards stack awkwardly, or whitespace becomes excessive -- and set a breakpoint there. Device-specific breakpoints leave gaps where content breaks but no breakpoint catches it, causing layout failures on the thousands of screen sizes between standard device widths.

**Incorrect (device-width breakpoints miss content overflow):**

```html
<!-- Breakpoints at 768px and 1024px, but the 3-column card grid
     actually breaks at ~680px where cards get too narrow to read -->
<div class="grid grid-cols-3 gap-6 max-[768px]:grid-cols-1 px-8">
  <div class="rounded-lg border border-gray-200 p-6">
    <h3 class="text-lg font-semibold">Annual Plan</h3>
    <!-- At 700px: 3 columns still active, cards are 190px wide,
         text wraps badly, price overflows -->
    <p class="text-3xl font-bold">$199/year</p>
    <p class="text-gray-600">Best for teams that need unlimited access to all features</p>
  </div>
  <!-- ...two more cards -->
</div>
```

**Correct (breakpoint set where content actually breaks):**

```css
/* tailwind.config — or @theme in v4 */
@theme {
  --breakpoint-cards: 42rem; /* ~672px — where 3-col cards get too narrow */
}
```

```html
<!-- Custom breakpoint matches where the content stops working -->
<div class="grid grid-cols-1 gap-6 px-4 cards:grid-cols-3 cards:gap-6 cards:px-8">
  <div class="rounded-lg border border-gray-200 p-6">
    <h3 class="text-lg font-semibold">Annual Plan</h3>
    <p class="text-3xl font-bold">$199/year</p>
    <p class="text-gray-600">Best for teams that need unlimited access to all features</p>
  </div>
  <!-- ...two more cards — columns kick in exactly when cards have room -->
</div>
```
