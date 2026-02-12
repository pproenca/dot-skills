---
title: Avoid Device-Specific Breakpoint Values
impact: HIGH
impactDescription: future-proofs layout across 4 to 5 yearly device size changes
tags: bp, device-widths, future-proof, breakpoint-values
---

## Avoid Device-Specific Breakpoint Values

Device widths change yearly -- foldables, new tablet sizes, and manufacturer-specific resolutions make device-targeting a losing game. There are over 15,000 distinct screen sizes in active use. Designing for specific devices (iPhone 15, iPad Air, MacBook Pro) creates fragile layouts that silently break when the next hardware generation ships with a slightly different viewport.

**Incorrect (device-specific breakpoints tied to hardware):**

```css
@theme {
  --breakpoint-phone: 375px;   /* iPhone 15 */
  --breakpoint-phone-lg: 430px; /* iPhone 15 Pro Max */
  --breakpoint-tablet: 768px;   /* iPad Mini */
  --breakpoint-tablet-lg: 1024px; /* iPad Pro 11" */
  --breakpoint-laptop: 1440px;  /* MacBook Pro 14" */
}
```

```html
<!-- Tied to specific Apple devices — breaks on Samsung, Pixel, Surface -->
<header class="phone:px-4 tablet:px-8 laptop:px-16 flex items-center justify-between">
  <span class="phone:text-sm tablet:text-base laptop:text-lg font-semibold">Acme Inc</span>
  <nav class="phone:hidden tablet:flex gap-6">
    <a href="/products" class="text-gray-700">Products</a>
    <a href="/pricing" class="text-gray-700">Pricing</a>
  </nav>
</header>
```

**Correct (content-oriented breakpoint ranges):**

```html
<!-- Tailwind defaults (640, 768, 1024, 1280) are content-range oriented,
     not device-specific — they work across all screen sizes -->
<header class="flex items-center justify-between px-4 sm:px-6 lg:px-16">
  <span class="text-sm font-semibold sm:text-base lg:text-lg">Acme Inc</span>
  <nav class="hidden sm:flex gap-6">
    <a href="/products" class="text-gray-700">Products</a>
    <a href="/pricing" class="text-gray-700">Pricing</a>
  </nav>
</header>
```

**When custom breakpoints are needed**, define them by content behavior, not device names:

```css
@theme {
  --breakpoint-content-narrow: 32rem;  /* where single-column content fits */
  --breakpoint-content-wide: 64rem;    /* where multi-column layout works */
}
```
