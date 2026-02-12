---
title: Use Responsive Container Padding
impact: MEDIUM
impactDescription: prevents content from touching screen edges on mobile
tags: rspac, container, padding, horizontal, edges
---

## Use Responsive Container Padding

Container horizontal padding must adapt to the viewport. A fixed `px-8` (32px per side = 64px total) on a 375px mobile screen surrenders 17% of the width to padding alone, leaving only 311px for content. On desktop, that same 32px feels tight against a 1440px viewport. Scale container padding from compact on mobile (16px) to generous on desktop (32px+), or use Tailwind's `container` class with responsive padding utilities.

**Incorrect (fixed container padding wastes mobile width):**

```html
<!-- px-8 = 32px per side — 64px total consumed on a 375px screen, only 311px left for content -->
<div class="mx-auto max-w-7xl px-8">
  <header class="flex items-center justify-between py-4">
    <a href="/" class="text-xl font-bold text-gray-900">Acme Inc</a>
    <nav class="flex items-center space-x-6">
      <a href="/products" class="text-sm text-gray-600 hover:text-gray-900">Products</a>
      <a href="/pricing" class="text-sm text-gray-600 hover:text-gray-900">Pricing</a>
      <a href="/about" class="text-sm text-gray-600 hover:text-gray-900">About</a>
      <a href="/signup" class="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700">Sign Up</a>
    </nav>
  </header>
  <main class="py-12">
    <h1 class="text-4xl font-extrabold tracking-tight text-gray-900">Build Better Products</h1>
    <p class="mt-4 max-w-2xl text-lg text-gray-500">The all-in-one platform for teams who ship fast and iterate often.</p>
    <div class="mt-10 grid grid-cols-3 gap-8">
      <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <h3 class="font-semibold text-gray-900">Analytics</h3>
        <p class="mt-2 text-sm text-gray-500">Real-time metrics and dashboards for every team member.</p>
      </div>
      <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <h3 class="font-semibold text-gray-900">Automation</h3>
        <p class="mt-2 text-sm text-gray-500">Automate repetitive workflows with no-code triggers.</p>
      </div>
      <div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
        <h3 class="font-semibold text-gray-900">Collaboration</h3>
        <p class="mt-2 text-sm text-gray-500">Share, comment, and iterate together in real time.</p>
      </div>
    </div>
  </main>
</div>
```

**Correct (responsive container padding: compact mobile, generous desktop):**

```html
<!-- px-4 (16px) mobile → px-6 (24px) tablet → px-8 (32px) desktop — content never touches edges, space is never wasted -->
<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
  <header class="flex items-center justify-between py-4">
    <a href="/" class="text-xl font-bold text-gray-900">Acme Inc</a>
    <nav class="hidden items-center space-x-6 md:flex">
      <a href="/products" class="text-sm text-gray-600 hover:text-gray-900">Products</a>
      <a href="/pricing" class="text-sm text-gray-600 hover:text-gray-900">Pricing</a>
      <a href="/about" class="text-sm text-gray-600 hover:text-gray-900">About</a>
      <a href="/signup" class="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700">Sign Up</a>
    </nav>
    <button class="rounded-md p-2 text-gray-600 md:hidden" aria-label="Open menu">
      <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" /></svg>
    </button>
  </header>
  <main class="py-8 md:py-12">
    <h1 class="text-3xl font-extrabold tracking-tight text-gray-900 md:text-4xl">Build Better Products</h1>
    <p class="mt-3 max-w-2xl text-lg text-gray-500 md:mt-4">The all-in-one platform for teams who ship fast and iterate often.</p>
    <div class="mt-8 grid grid-cols-1 gap-4 sm:grid-cols-2 md:mt-10 md:gap-6 lg:grid-cols-3 lg:gap-8">
      <div class="rounded-xl border border-gray-200 bg-white p-5 shadow-sm md:p-6">
        <h3 class="font-semibold text-gray-900">Analytics</h3>
        <p class="mt-2 text-sm text-gray-500">Real-time metrics and dashboards for every team member.</p>
      </div>
      <div class="rounded-xl border border-gray-200 bg-white p-5 shadow-sm md:p-6">
        <h3 class="font-semibold text-gray-900">Automation</h3>
        <p class="mt-2 text-sm text-gray-500">Automate repetitive workflows with no-code triggers.</p>
      </div>
      <div class="rounded-xl border border-gray-200 bg-white p-5 shadow-sm md:p-6">
        <h3 class="font-semibold text-gray-900">Collaboration</h3>
        <p class="mt-2 text-sm text-gray-500">Share, comment, and iterate together in real time.</p>
      </div>
    </div>
  </main>
</div>
```
