---
title: Replace Fixed Positioning with Relative on Mobile
impact: MEDIUM-HIGH
impactDescription: prevents overlapping content and z-index battles on small screens
tags: layout, fixed, relative, positioning, mobile, z-index
---

## Replace Fixed Positioning with Relative on Mobile

Fixed-position elements (floating action buttons, chat widgets, cookie banners) are placed relative to the viewport and float above page content. On mobile, these elements can obscure text, overlap form inputs, or block tap targets -- especially near the bottom of the screen where thumbs naturally rest. Converting them to relative or integrating them into the document flow on mobile eliminates overlap and simplifies z-index management.

**Incorrect (fixed FAB that covers content on mobile):**

```html
<div class="relative min-h-screen">
  <main class="p-4">
    <h1 class="text-xl font-bold">Help Center</h1>
    <div class="mt-4 space-y-4">
      <article class="rounded-lg border p-4">
        <h2 class="font-medium">Getting Started Guide</h2>
        <p class="mt-1 text-sm text-gray-600">Learn the basics of setting up your account.</p>
        <a href="#" class="mt-2 inline-block text-sm text-blue-600">Read more</a>
      </article>
      <article class="rounded-lg border p-4">
        <h2 class="font-medium">Billing FAQ</h2>
        <p class="mt-1 text-sm text-gray-600">Common questions about plans and payments.</p>
        <a href="#" class="mt-2 inline-block text-sm text-blue-600">Read more</a>
      </article>
    </div>
  </main>

  <!-- Covers the "Read more" links and bottom content on mobile -->
  <button class="fixed bottom-4 right-4 z-50 rounded-full bg-blue-600 p-4 text-white shadow-lg">
    <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" />
    </svg>
  </button>
</div>
```

**Correct (inline on mobile, fixed on desktop):**

```html
<div class="relative min-h-screen">
  <main class="p-4">
    <h1 class="text-xl font-bold">Help Center</h1>
    <div class="mt-4 space-y-4">
      <article class="rounded-lg border p-4">
        <h2 class="font-medium">Getting Started Guide</h2>
        <p class="mt-1 text-sm text-gray-600">Learn the basics of setting up your account.</p>
        <a href="#" class="mt-2 inline-block text-sm text-blue-600">Read more</a>
      </article>
      <article class="rounded-lg border p-4">
        <h2 class="font-medium">Billing FAQ</h2>
        <p class="mt-1 text-sm text-gray-600">Common questions about plans and payments.</p>
        <a href="#" class="mt-2 inline-block text-sm text-blue-600">Read more</a>
      </article>
    </div>

    <!-- On mobile: full-width button at the bottom of content flow -->
    <!-- On md+: fixed floating button in the corner -->
    <div class="mt-6 md:mt-0">
      <button class="w-full rounded-lg bg-blue-600 px-4 py-3 text-center text-sm font-medium text-white shadow md:fixed md:bottom-4 md:right-4 md:z-50 md:w-auto md:rounded-full md:p-4">
        <span class="md:hidden">Chat with Support</span>
        <svg class="hidden h-6 w-6 md:block" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" />
        </svg>
      </button>
    </div>
  </main>
</div>
```

**Key principle:** Use `md:fixed md:bottom-4 md:right-4` instead of unconditional `fixed`. On mobile, render the element inline as a full-width button or bar at a logical place in the content flow. This avoids overlap, eliminates z-index issues, and often provides a better mobile UX since the action is visible in context rather than floating on top.
