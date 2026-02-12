---
title: Use Compact Spacing on Mobile, Generous on Desktop
impact: HIGH
impactDescription: 2-3× spacing reduction on mobile vs desktop
tags: rspac, density, mobile, desktop, vertical-spacing
---

## Use Compact Spacing on Mobile, Generous on Desktop

Mobile screens demand higher information density -- users see less content per scroll and have limited viewport height (typically 667-812px). Desktop has abundant space where generous whitespace improves readability and visual hierarchy. Applying the same large spacing everywhere forces mobile users through excessive scrolling while wasting the real estate desktop provides. Design spacing that compacts on small screens and breathes on large ones.

**Incorrect (same generous spacing everywhere causes excessive mobile scrolling):**

```html
<!-- py-24 = 96px top + 96px bottom per section — three sections consume 576px of vertical space in padding alone -->
<main>
  <section class="py-24">
    <div class="mx-auto max-w-4xl px-4">
      <h2 class="text-3xl font-bold text-gray-900">Why Choose Us</h2>
      <p class="mt-6 text-lg text-gray-600">We deliver results that speak for themselves with a team of dedicated experts.</p>
      <div class="mt-12 grid grid-cols-1 gap-8 sm:grid-cols-3">
        <div class="text-center">
          <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-blue-100 text-blue-600">
            <svg class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
          </div>
          <h3 class="mt-4 font-semibold text-gray-900">Lightning Fast</h3>
          <p class="mt-2 text-sm text-gray-500">Sub-second load times globally.</p>
        </div>
        <div class="text-center">
          <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-green-100 text-green-600">
            <svg class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>
          </div>
          <h3 class="mt-4 font-semibold text-gray-900">Secure</h3>
          <p class="mt-2 text-sm text-gray-500">Enterprise-grade encryption.</p>
        </div>
        <div class="text-center">
          <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-purple-100 text-purple-600">
            <svg class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" /></svg>
          </div>
          <h3 class="mt-4 font-semibold text-gray-900">Loved</h3>
          <p class="mt-2 text-sm text-gray-500">4.9-star average rating.</p>
        </div>
      </div>
    </div>
  </section>
  <section class="py-24 bg-gray-50">
    <div class="mx-auto max-w-4xl px-4">
      <h2 class="text-3xl font-bold text-gray-900">Trusted by Thousands</h2>
      <p class="mt-6 text-lg text-gray-600">Join 10,000+ companies already using our platform.</p>
    </div>
  </section>
</main>
```

**Correct (compact mobile spacing, generous desktop spacing):**

```html
<!-- py-8 (32px) mobile → py-16 (64px) tablet → py-24 (96px) desktop — density matches the viewport -->
<main>
  <section class="py-8 md:py-16 lg:py-24">
    <div class="mx-auto max-w-4xl px-4">
      <h2 class="text-2xl font-bold text-gray-900 md:text-3xl">Why Choose Us</h2>
      <p class="mt-3 text-base text-gray-600 md:mt-6 md:text-lg">We deliver results that speak for themselves with a team of dedicated experts.</p>
      <div class="mt-6 grid grid-cols-1 gap-6 sm:grid-cols-3 md:mt-12 md:gap-8">
        <div class="text-center">
          <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-blue-100 text-blue-600">
            <svg class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
          </div>
          <h3 class="mt-3 font-semibold text-gray-900 md:mt-4">Lightning Fast</h3>
          <p class="mt-1 text-sm text-gray-500 md:mt-2">Sub-second load times globally.</p>
        </div>
        <div class="text-center">
          <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-green-100 text-green-600">
            <svg class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>
          </div>
          <h3 class="mt-3 font-semibold text-gray-900 md:mt-4">Secure</h3>
          <p class="mt-1 text-sm text-gray-500 md:mt-2">Enterprise-grade encryption.</p>
        </div>
        <div class="text-center">
          <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-purple-100 text-purple-600">
            <svg class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" /></svg>
          </div>
          <h3 class="mt-3 font-semibold text-gray-900 md:mt-4">Loved</h3>
          <p class="mt-1 text-sm text-gray-500 md:mt-2">4.9-star average rating.</p>
        </div>
      </div>
    </div>
  </section>
  <section class="bg-gray-50 py-8 md:py-16 lg:py-24">
    <div class="mx-auto max-w-4xl px-4">
      <h2 class="text-2xl font-bold text-gray-900 md:text-3xl">Trusted by Thousands</h2>
      <p class="mt-3 text-base text-gray-600 md:mt-6 md:text-lg">Join 10,000+ companies already using our platform.</p>
    </div>
  </section>
</main>
```
