---
title: Collapse Horizontal Nav to Hamburger on Mobile
impact: MEDIUM-HIGH
impactDescription: prevents nav overflow on screens under 768px
tags: nav, hamburger, mobile-first, overflow, responsive
---

## Collapse Horizontal Nav to Hamburger on Mobile

Horizontal navigation with 5+ links overflows or wraps awkwardly on mobile screens. On a 375px viewport, six nav links with spacing simply cannot fit in a single row — they either overflow off-screen or wrap into multiple lines, both of which break the visual hierarchy and confuse users. Replace the horizontal link list with a hamburger toggle that reveals a vertical menu on mobile, keeping the full horizontal nav on wider screens.

**Incorrect (horizontal nav links overflow or wrap on mobile):**

```html
<!-- Six links at ~80px each plus gap-6 spacing need ~560px — overflows a 375px screen -->
<header class="border-b bg-white px-4 py-3">
  <nav class="flex items-center justify-between">
    <a href="/" class="text-xl font-bold">Acme</a>
    <div class="flex gap-6">
      <a href="/products" class="text-sm font-medium text-gray-700 hover:text-gray-900">Products</a>
      <a href="/solutions" class="text-sm font-medium text-gray-700 hover:text-gray-900">Solutions</a>
      <a href="/pricing" class="text-sm font-medium text-gray-700 hover:text-gray-900">Pricing</a>
      <a href="/docs" class="text-sm font-medium text-gray-700 hover:text-gray-900">Documentation</a>
      <a href="/blog" class="text-sm font-medium text-gray-700 hover:text-gray-900">Blog</a>
      <a href="/contact" class="text-sm font-medium text-gray-700 hover:text-gray-900">Contact</a>
    </div>
  </nav>
</header>
```

**Correct (hamburger on mobile, full horizontal nav on desktop):**

```html
<!-- Links hidden on mobile behind a hamburger toggle, visible as a row from md up -->
<header class="border-b bg-white px-4 py-3">
  <nav class="flex items-center justify-between">
    <a href="/" class="text-xl font-bold">Acme</a>

    <!-- Hamburger button — visible only on mobile -->
    <button
      type="button"
      aria-label="Toggle menu"
      aria-expanded="false"
      data-toggle="mobile-menu"
      class="inline-flex items-center justify-center rounded-md p-2 text-gray-700 hover:bg-gray-100 md:hidden"
    >
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
      </svg>
    </button>

    <!-- Desktop nav links — hidden on mobile, flex row from md up -->
    <div class="hidden md:flex md:gap-6">
      <a href="/products" class="text-sm font-medium text-gray-700 hover:text-gray-900">Products</a>
      <a href="/solutions" class="text-sm font-medium text-gray-700 hover:text-gray-900">Solutions</a>
      <a href="/pricing" class="text-sm font-medium text-gray-700 hover:text-gray-900">Pricing</a>
      <a href="/docs" class="text-sm font-medium text-gray-700 hover:text-gray-900">Documentation</a>
      <a href="/blog" class="text-sm font-medium text-gray-700 hover:text-gray-900">Blog</a>
      <a href="/contact" class="text-sm font-medium text-gray-700 hover:text-gray-900">Contact</a>
    </div>
  </nav>

  <!-- Mobile menu panel — toggled via JS, hidden by default, never shown on md+ -->
  <div id="mobile-menu" class="hidden flex-col gap-1 pb-3 pt-2 md:hidden">
    <a href="/products" class="rounded-md px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100">Products</a>
    <a href="/solutions" class="rounded-md px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100">Solutions</a>
    <a href="/pricing" class="rounded-md px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100">Pricing</a>
    <a href="/docs" class="rounded-md px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100">Documentation</a>
    <a href="/blog" class="rounded-md px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100">Blog</a>
    <a href="/contact" class="rounded-md px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100">Contact</a>
  </div>
</header>
```

**Key principle:** Use `hidden md:flex md:gap-6` on the desktop link container and `md:hidden` on the hamburger button. The mobile menu panel uses `md:hidden` so it can never appear on desktop, and JS toggles the `hidden` class on that panel. Always include `aria-label` and `aria-expanded` on the hamburger button for accessibility.
