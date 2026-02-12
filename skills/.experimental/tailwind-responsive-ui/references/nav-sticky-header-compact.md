---
title: Compact the Header on Scroll for Mobile
impact: LOW-MEDIUM
impactDescription: recovers 30 to 40px of viewport after scroll
tags: nav, sticky-header, scroll, compact, responsive
---

## Compact the Header on Scroll for Mobile

Mobile headers with logos, search fields, and navigation actions can consume 80-120px of vertical space. On a 667px viewport, that is 12-18% of the screen permanently occupied by chrome instead of content. After the user has scrolled past the initial view, they have committed to the content — compacting the header to its essential elements (logo + primary actions) recovers 30-40px of viewport without losing navigability.

**Incorrect (tall header stays at full height permanently on mobile):**

```html
<!-- 80px header permanently consumes 12% of a 667px mobile viewport -->
<header class="sticky top-0 z-50 h-20 border-b bg-white shadow-sm">
  <div class="flex h-full items-center justify-between px-4">
    <a href="/" class="flex items-center gap-2">
      <img src="/logo.svg" alt="SiteLogoLarge" class="h-10 w-10" />
      <span class="text-lg font-bold">BrandName</span>
    </a>

    <!-- Search field always visible at full size -->
    <div class="mx-4 flex-1">
      <div class="relative">
        <input
          type="search"
          placeholder="Search products, articles..."
          class="w-full rounded-full border bg-gray-50 py-2.5 pl-10 pr-4 text-sm"
        />
        <svg class="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
      </div>
    </div>

    <div class="flex items-center gap-3">
      <button type="button" aria-label="Notifications" class="rounded-full p-2 text-gray-600 hover:bg-gray-100">
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" /></svg>
      </button>
      <button type="button" aria-label="Account" class="rounded-full p-2 text-gray-600 hover:bg-gray-100">
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
      </button>
    </div>
  </div>
</header>
```

**Correct (header compacts on scroll, hiding search and shrinking logo on mobile):**

```html
<!-- Header transitions from h-20 to h-14 on scroll via JS-toggled class -->
<header
  id="site-header"
  class="sticky top-0 z-50 border-b bg-white shadow-sm transition-all duration-300 ease-in-out"
  data-compact="false"
>
  <!-- Full header state: h-20 with search visible -->
  <div class="flex h-20 items-center justify-between px-4 transition-all duration-300 [.header-compact_&]:h-14">
    <a href="/" class="flex items-center gap-2">
      <img
        src="/logo.svg"
        alt="SiteLogo"
        class="h-10 w-10 transition-all duration-300 [.header-compact_&]:h-7 [.header-compact_&]:w-7"
      />
      <span class="text-lg font-bold transition-all duration-300 [.header-compact_&]:text-base">BrandName</span>
    </a>

    <!-- Search field — hidden when compacted on mobile, always visible on desktop -->
    <div class="mx-4 hidden flex-1 md:block [.header-compact_&]:hidden [.header-compact_&]:md:block">
      <div class="relative">
        <input
          type="search"
          placeholder="Search products, articles..."
          class="w-full rounded-full border bg-gray-50 py-2 pl-10 pr-4 text-sm"
        />
        <svg class="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
      </div>
    </div>

    <div class="flex items-center gap-2">
      <!-- Search icon — shown only in compact mobile state as a replacement -->
      <button
        type="button"
        aria-label="Search"
        class="hidden rounded-full p-2 text-gray-600 hover:bg-gray-100 [.header-compact_&]:inline-flex [.header-compact_&]:md:hidden"
      >
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
      </button>
      <button type="button" aria-label="Notifications" class="rounded-full p-2 text-gray-600 hover:bg-gray-100">
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" /></svg>
      </button>
      <button type="button" aria-label="Account" class="rounded-full p-2 text-gray-600 hover:bg-gray-100">
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
      </button>
    </div>
  </div>
</header>

<!-- Scroll listener toggles the .header-compact class on #site-header -->
<script>
  const header = document.getElementById('site-header');
  let lastScroll = 0;
  window.addEventListener('scroll', () => {
    const scrollY = window.scrollY;
    if (scrollY > 60) {
      header.classList.add('header-compact');
    } else {
      header.classList.remove('header-compact');
    }
    lastScroll = scrollY;
  }, { passive: true });
</script>
```

**Key principle:** Use a JS scroll listener to toggle a parent class (e.g., `.header-compact`) after a scroll threshold (60px). Tailwind's arbitrary variant `[.header-compact_&]` lets child elements react to the parent state — shrinking the logo, hiding the search field on mobile, and reducing the header height. Keep `transition-all duration-300` on affected elements for smooth visual transitions. On desktop (`md:`), keep the search field visible even in the compact state.
