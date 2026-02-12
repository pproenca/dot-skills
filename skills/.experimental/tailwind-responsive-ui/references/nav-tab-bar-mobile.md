---
title: Use Bottom Tab Bar for Primary Mobile Navigation
impact: MEDIUM-HIGH
impactDescription: improves mobile reachability — bottom 50% of screen is easiest to tap
tags: nav, tab-bar, mobile, reachability, touch
---

## Use Bottom Tab Bar for Primary Mobile Navigation

For apps with 3-5 primary sections, a bottom tab bar is significantly more thumb-friendly than a top hamburger menu. On modern phones with 6"+ screens, the top of the display sits in the hardest-to-reach zone. A bottom tab bar keeps primary navigation within the natural thumb arc, reducing interaction cost and increasing feature discoverability since all sections are visible at once.

**Incorrect (hamburger menu at top forces long thumb reach on mobile):**

```html
<!-- User must stretch to top-left corner on a 6.7" phone to access primary navigation -->
<header class="sticky top-0 z-50 border-b bg-white px-4 py-3">
  <div class="flex items-center justify-between">
    <button type="button" aria-label="Open menu" class="rounded-md p-2 text-gray-700 hover:bg-gray-100">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
      </svg>
    </button>
    <span class="text-lg font-bold">AppName</span>
    <div class="w-10"></div>
  </div>
</header>

<!-- Hidden until hamburger toggled — all sections buried behind one tap -->
<nav id="mobile-nav" class="hidden fixed inset-0 z-40 bg-white p-6">
  <a href="/home" class="block py-3 text-lg font-medium text-gray-900">Home</a>
  <a href="/search" class="block py-3 text-lg font-medium text-gray-900">Search</a>
  <a href="/orders" class="block py-3 text-lg font-medium text-gray-900">Orders</a>
  <a href="/favorites" class="block py-3 text-lg font-medium text-gray-900">Favorites</a>
  <a href="/account" class="block py-3 text-lg font-medium text-gray-900">Account</a>
</nav>
```

**Correct (bottom tab bar on mobile, sidebar or top nav on desktop):**

```html
<!-- Bottom tabs for mobile, traditional sidebar for desktop -->
<div class="flex min-h-screen flex-col md:flex-row">

  <!-- Desktop sidebar — hidden on mobile -->
  <aside class="hidden md:flex md:w-56 md:shrink-0 md:flex-col md:border-r md:bg-gray-50 md:p-4">
    <span class="mb-6 text-lg font-bold">AppName</span>
    <nav class="flex flex-col gap-1">
      <a href="/home" class="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-gray-900 bg-gray-100">
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-4 0h4" /></svg>
        Home
      </a>
      <a href="/search" class="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100">
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>
        Search
      </a>
      <a href="/orders" class="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100">
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 012-2h2a2 2 0 012 2M9 5h6" /></svg>
        Orders
      </a>
      <a href="/favorites" class="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100">
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" /></svg>
        Favorites
      </a>
      <a href="/account" class="flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100">
        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
        Account
      </a>
    </nav>
  </aside>

  <!-- Main content — add bottom padding on mobile to clear the fixed tabs -->
  <main class="flex-1 pb-20 md:pb-0">
    <!-- Page content here -->
  </main>

  <!-- Mobile bottom tab strip — fixed at bottom, hidden on md+ -->
  <nav class="fixed bottom-0 inset-x-0 z-50 flex justify-around border-t bg-white pb-[env(safe-area-inset-bottom)] md:hidden">
    <a href="/home" class="flex flex-col items-center gap-1 px-3 py-2 text-xs font-medium text-blue-600">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-4 0h4" /></svg>
      Home
    </a>
    <a href="/search" class="flex flex-col items-center gap-1 px-3 py-2 text-xs font-medium text-gray-500">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>
      Search
    </a>
    <a href="/orders" class="flex flex-col items-center gap-1 px-3 py-2 text-xs font-medium text-gray-500">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 012-2h2a2 2 0 012 2M9 5h6" /></svg>
      Orders
    </a>
    <a href="/favorites" class="flex flex-col items-center gap-1 px-3 py-2 text-xs font-medium text-gray-500">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" /></svg>
      Favorites
    </a>
    <a href="/account" class="flex flex-col items-center gap-1 px-3 py-2 text-xs font-medium text-gray-500">
      <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
      Account
    </a>
  </nav>
</div>
```

**Key principle:** Use `fixed bottom-0 inset-x-0 md:hidden` for the mobile tab strip and `hidden md:flex` for the desktop sidebar. Add `pb-20 md:pb-0` to the main content area so it does not get obscured by the fixed tab strip. Include `pb-safe` on the tab strip to account for the home indicator on notched devices.
